import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/state_views.dart';

/// `POST /gyms/:gymId/qr-check-in-token/rotate` — the printed self-check-in
/// QR poster. The secret is only ever returned once, right here, to staff —
/// never exposed on the member-facing gym read. Rotating instantly
/// invalidates a leaked/photographed poster.
class CheckinPosterScreen extends ConsumerStatefulWidget {
  const CheckinPosterScreen({super.key});

  @override
  ConsumerState<CheckinPosterScreen> createState() => _CheckinPosterScreenState();
}

class _CheckinPosterScreenState extends ConsumerState<CheckinPosterScreen> {
  String? _token;
  bool _loading = false;
  String? _error;

  Future<void> _rotate({bool confirmFirst = false}) async {
    if (confirmFirst) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.bgSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Rotate check-in code?', style: TextStyle(color: AppColors.textPrimary)),
          content: const Text(
            'Any previously printed poster will stop working immediately. Print and put up the new one before removing the old.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Rotate', style: TextStyle(color: AppColors.accentOrange))),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ref.read(gymOwnerServiceProvider).rotateCheckInToken(gymId);
      if (mounted) {
        setState(() {
          _token = res['qrCheckInSecret'] as String?;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = friendlyApiError(e); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Check-in Poster', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(message: 'Generating…');
    if (_error != null) return ErrorRetryView(message: _error!, onRetry: () => _rotate());

    if (_token == null) {
      return EmptyStateView(
        icon: Icons.qr_code_2_rounded,
        title: 'Generate your check-in poster',
        subtitle: 'Members scan this printed QR at the front desk to self check-in. You can rotate it any time a poster is lost or photographed.',
        actionLabel: 'Generate QR',
        onAction: () => _rotate(),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: [
        Center(
          child: Column(
            children: [
              Text('Print this and put it up at the front desk',
                  textAlign: TextAlign.center, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: QrImageView(data: _token!, size: 240, backgroundColor: Colors.white),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppColors.bgTertiary, borderRadius: BorderRadius.circular(10)),
                child: Text(_token!, style: AppTextStyles.caption.copyWith(fontFamily: 'monospace', color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _rotate(confirmFirst: true),
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.accentOrange),
                  label: const Text('Rotate (invalidate old poster)', style: TextStyle(color: AppColors.accentOrange)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.accentOrange.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
