import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/member_entitlements.dart';
import '../../providers/entitlements_provider.dart';
import '../../theme/app_theme.dart';
import '../screens/billing_plans_screen.dart';

/// Wraps a premium feature (AI plans / trainer chat / nutrition analysis)
/// and shows it dimmed with an upgrade prompt when the user's entitlements
/// don't unlock it — driven entirely by `entitlementsProvider`
/// (`GET /subscriptions/me/entitlements`), never local guessing, per
/// feature-specification.md §1.5.
///
/// Fails open on loading/error: the backend enforces the real gate on every
/// premium endpoint regardless (FE gating here is UX, not security), so a
/// slow network shouldn't flash a false lock over content the user may
/// already be entitled to.
class PremiumGate extends ConsumerWidget {
  const PremiumGate({
    super.key,
    required this.feature,
    required this.featureLabel,
    required this.child,
  });

  /// Selects the relevant boolean off [MemberEntitlements], e.g.
  /// `(e) => e.aiPlans`.
  final bool Function(MemberEntitlements) feature;

  /// Shown in the upsell copy, e.g. "AI-generated plans".
  final String featureLabel;

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitlementsAsync = ref.watch(entitlementsProvider);

    return entitlementsAsync.when(
      data: (ent) => feature(ent) ? child : _buildLocked(context),
      loading: () => child,
      error: (_, __) => child,
    );
  }

  Widget _buildLocked(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.3,
          child: IgnorePointer(child: child),
        ),
        Positioned.fill(
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BillingPlansScreen()),
              ),
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.4)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_rounded, color: AppColors.accentBlue, size: 22),
                    const SizedBox(height: 6),
                    Text(
                      '$featureLabel is a premium feature',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to upgrade or start your free trial',
                      style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
