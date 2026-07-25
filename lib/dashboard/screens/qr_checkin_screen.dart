import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/gym_provider.dart';
import '../../services/member_service.dart';
import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';

/// Screen allowing a Member to perform self check-in by submitting a QR token or code.
class QrCheckinScreen extends ConsumerStatefulWidget {
  const QrCheckinScreen({super.key});

  @override
  ConsumerState<QrCheckinScreen> createState() => _QrCheckinScreenState();
}

class _QrCheckinScreenState extends ConsumerState<QrCheckinScreen> {
  final _qrTokenController = TextEditingController();
  bool _loading = false;
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _qrTokenController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckin() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null || gymId.isEmpty) {
      setState(() {
        _statusMessage = 'No active gym selected. Please join a gym first.';
        _isSuccess = false;
      });
      return;
    }

    final token = _qrTokenController.text.trim();
    if (token.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter or scan a QR code token';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _statusMessage = null;
    });

    try {
      final service = ref.read(memberServiceProvider);
      await service.qrCheckIn(gymId: gymId, qrToken: token);

      if (mounted) {
        setState(() {
          _loading = false;
          _isSuccess = true;
          _statusMessage = 'Check-in successful! Welcome to the gym.';
          _qrTokenController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _isSuccess = false;
          _statusMessage = 'Check-in failed: Invalid or expired QR code.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gymId = ref.watch(currentGymIdProvider);
    final selectedGym = ref.watch(selectedGymProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('QR Self Check-in', style: TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectedGym != null) ...[
                DashboardGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.fitness_center_rounded, color: AppColors.accentBlue, size: 24),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedGym.gymName ?? 'Active Gym',
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Gym ID: ${selectedGym.gymId}',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Text(
                'Scan or Enter QR Code',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Scan the QR code displayed at the gym front desk or enter the token below.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Mock QR scanner graphic container
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.4), width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_scanner_rounded, size: 64, color: AppColors.accentBlue),
                      const SizedBox(height: 10),
                      Text(
                        'Scanner Active',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _qrTokenController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'QR Code Token',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: 'Paste or type QR token',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.bgSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.glassBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.accentBlue),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_loading || gymId == null) ? null : _handleCheckin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Check In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),

              if (_statusMessage != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (_isSuccess ? const Color(0xFF16A34A) : AppColors.accentCoral)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (_isSuccess ? const Color(0xFF4ADE80) : AppColors.accentCoral)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                        color: _isSuccess ? const Color(0xFF4ADE80) : AppColors.accentCoral,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: TextStyle(
                            color: _isSuccess ? const Color(0xFF4ADE80) : AppColors.accentCoral,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
