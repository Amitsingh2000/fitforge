import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/member_entitlements.dart';
import '../services/member_service.dart';

/// Shared paywall truth — `GET /subscriptions/me/entitlements`. Any screen
/// that needs to gate a premium feature (aiPlans / trainerChat /
/// nutritionAnalysis) should watch this instead of fetching its own copy or
/// guessing locally, per feature-specification.md §1.5: "FE must drive all
/// premium gating off this response, not local logic." Auto-refreshes on
/// first watch per screen; call `ref.invalidate(entitlementsProvider)` after
/// a trial starts or a purchase completes so gates unlock immediately.
final entitlementsProvider = FutureProvider<MemberEntitlements>((ref) async {
  final service = ref.watch(memberServiceProvider);
  return service.getMyEntitlements();
});
