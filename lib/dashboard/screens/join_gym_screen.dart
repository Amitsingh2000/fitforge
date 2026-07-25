import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/gym_membership.dart';
import '../../providers/gym_provider.dart';
import '../../services/member_service.dart';
import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';

/// Screen allowing a Normal User to join a gym using an invite code.
class JoinGymScreen extends ConsumerStatefulWidget {
  const JoinGymScreen({super.key});

  @override
  ConsumerState<JoinGymScreen> createState() => _JoinGymScreenState();
}

class _JoinGymScreenState extends ConsumerState<JoinGymScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;
  Map<String, dynamic>? _joinedGymData;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter an invite code');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(memberServiceProvider);
      final res = await service.joinGym(code);

      final gymId = res['gymId'] as String? ?? res['gym']?['id'] as String? ?? '';
      final membershipId = res['membershipId'] as String? ?? res['id'] as String? ?? '';

      // Update active gym context if gymId is present
      if (gymId.isNotEmpty) {
        ref.read(selectedGymProvider.notifier).state = GymMembership(
          gymId: gymId,
          gymName: res['gymName'] as String? ?? res['gym']?['name'] as String?,
          role: GymRole.member,
          membershipId: membershipId,
        );
      }

      if (mounted) {
        setState(() {
          _loading = false;
          _joinedGymData = res;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined gym!'),
            backgroundColor: AppColors.accentBlue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = 'Invalid or expired invite code ($e)';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Join a Gym', style: TextStyle(color: AppColors.textPrimary)),
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
              Text(
                'Enter Gym Invite Code',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Ask your gym manager or trainer for your unique 6-digit invite code.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: AppColors.textPrimary, letterSpacing: 2.0, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'e.g. GYM123',
                  hintStyle: const TextStyle(color: AppColors.textTertiary, letterSpacing: 0),
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
                  errorText: _errorMessage,
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleJoin,
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
                      : const Text('Join Gym', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),

              if (_joinedGymData != null) ...[
                const SizedBox(height: 28),
                DashboardGlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.accentCyan, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _joinedGymData!['gymName'] as String? ?? 'Gym Joined',
                              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You are now connected to this gym. Attendance, announcements, and trainer features are now available.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
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
