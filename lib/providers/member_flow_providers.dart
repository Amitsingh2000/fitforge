import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_summary.dart';
import '../models/coaching_assignment.dart';
import '../models/dashboard_today.dart';
import '../models/diet_today.dart';
import '../models/leaderboard_entry.dart';
import '../models/marketplace_product.dart';
import '../models/member_subscription.dart';
import '../models/rewards_overview.dart';
import '../models/workout_today.dart';
import '../services/coaching_service.dart';
import '../services/gamification_service.dart';
import '../services/marketplace_service.dart';
import '../services/member_dashboard_service.dart';
import '../services/member_service.dart';
import 'entitlements_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Member-flow Riverpod providers.
//
// Screens watch FutureProviders for reads; after mutations call the service
// directly then invalidate the owning provider(s).
// ─────────────────────────────────────────────────────────────────────────────

/// Subscription state shared across billing/profile screens.
final memberSubscriptionProvider =
    FutureProvider<MemberSubscription>((ref) async {
  return ref.watch(memberServiceProvider).getMySubscription();
});

/// `GET /members/me/dashboard/today`
final todayDashboardProvider = FutureProvider<DashboardToday>((ref) {
  return ref.watch(memberDashboardServiceProvider).getToday();
});

/// `GET /members/me/diet/today`
final dietTodayProvider = FutureProvider<DietToday>((ref) {
  return ref.watch(memberDashboardServiceProvider).getDietToday();
});

/// `GET /members/me/workout/today`
final workoutTodayProvider = FutureProvider<WorkoutToday>((ref) {
  return ref.watch(memberDashboardServiceProvider).getWorkoutToday();
});

/// `GET /members/me/analytics/summary`
final analyticsSummaryProvider =
    FutureProvider.family<AnalyticsSummary, String>((ref, range) {
  return ref.watch(memberDashboardServiceProvider).getAnalyticsSummary(
        range: range,
      );
});

/// `GET /members/me/rewards/overview`
final rewardsOverviewProvider = FutureProvider<RewardsOverview>((ref) {
  return ref.watch(gamificationServiceProvider).getRewardsOverview();
});

/// Leaderboard query params bundled for the family key.
typedef LeaderboardQuery = ({
  String type,
  String scope,
  String? gymId,
  String filter,
  int limit,
});

/// `GET /leaderboards`
final leaderboardProvider =
    FutureProvider.family<LeaderboardResponse, LeaderboardQuery>((ref, q) {
  return ref.watch(gamificationServiceProvider).getLeaderboard(
        type: q.type,
        scope: q.scope,
        gymId: q.gymId,
        filter: q.filter,
        limit: q.limit,
      );
});

/// `GET /members/me/coaching`
final coachingProvider = FutureProvider<CoachingAssignment?>((ref) {
  return ref.watch(coachingServiceProvider).getMyCoaching();
});

/// `GET /marketplace/products`
final marketplaceProductsProvider =
    FutureProvider.family<PaginatedMarketplaceProducts, String?>((ref, gymId) {
  return ref.watch(marketplaceServiceProvider).listProducts(gymId: gymId);
});

/// `GET /challenges`
final challengesProvider =
    FutureProvider.family<List<Challenge>, String?>((ref, gymId) {
  return ref.watch(gamificationServiceProvider).listChallenges(gymId: gymId);
});

/// Call after checkout / trial start so paywall gates refresh immediately.
void invalidateMemberCommerce(WidgetRef ref) {
  ref.invalidate(entitlementsProvider);
  ref.invalidate(memberSubscriptionProvider);
}

/// ProviderRef variant for non-widget call sites.
void invalidateMemberCommerceFromRef(Ref ref) {
  ref.invalidate(entitlementsProvider);
  ref.invalidate(memberSubscriptionProvider);
}

/// Broader invalidation after daily-loop mutations (water, tasks, meal checks).
void invalidateDailyLoop(WidgetRef ref) {
  ref.invalidate(todayDashboardProvider);
  ref.invalidate(dietTodayProvider);
  ref.invalidate(workoutTodayProvider);
  ref.invalidate(rewardsOverviewProvider);
}

void invalidateDailyLoopFromRef(Ref ref) {
  ref.invalidate(todayDashboardProvider);
  ref.invalidate(dietTodayProvider);
  ref.invalidate(workoutTodayProvider);
  ref.invalidate(rewardsOverviewProvider);
}
