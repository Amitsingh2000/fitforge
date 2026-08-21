import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/chat_thread.dart';
import '../models/diet_plan.dart';
import '../models/exercise.dart';
import '../models/member_attendance.dart';
import '../models/member_profile.dart';
import '../models/member_progress_summary.dart';
import '../models/nutrition_log.dart';
import '../models/progress_entry.dart';
import '../models/trainer_analytics.dart';
import '../models/trainer_client.dart';
import '../models/trainer_dashboard.dart';
import '../models/trainer_notification.dart';
import '../models/trainer_profile.dart';
import '../models/workout_log.dart';
import '../models/workout_plan.dart';
import '../services/api_failure.dart';
import '../services/chat_service.dart';
import '../services/diet_plan_service.dart';
import '../services/member_management_service.dart';
import '../services/trainer_analytics_service.dart';
import '../services/trainer_dashboard_service.dart';
import '../services/trainer_service.dart';
import '../services/workout_plan_service.dart';
import 'gym_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Trainer-flow Riverpod providers.
//
// gymId is threaded from the app's active-gym state ([currentGymIdProvider])
// rather than passed ad hoc — every gym-scoped provider here reads it once.
// Reads are FutureProviders a screen can `watch`; mutations (create/update/
// assign/send/broadcast) are called imperatively on the service and the owning
// provider invalidated afterwards.
// ─────────────────────────────────────────────────────────────────────────────

/// Thrown by the convenience providers when no gym has been selected yet.
ApiFailure _noGym() => const ApiFailure(
      kind: ApiFailureKind.other,
      message: 'No gym selected. Select a gym to continue.',
    );

/// `GET /trainers/me/dashboard` — cross-gym, no gymId needed.
final trainerDashboardProvider = FutureProvider<TrainerDashboard>((ref) {
  return ref.watch(trainerDashboardServiceProvider).getDashboard();
});

/// `GET /trainers/me/notifications` — trainer's own alert feed, no gymId.
final trainerNotificationsProvider =
    FutureProvider<List<TrainerNotification>>((ref) {
  return ref.watch(trainerDashboardServiceProvider).getNotifications();
});

/// `GET /trainers/me/profile` — for headers/badges.
final trainerProfileProvider = FutureProvider<TrainerProfile>((ref) {
  return ref.watch(trainerServiceProvider).getMyProfile();
});

/// `GET /gyms/:gymId/trainer/clients` for the currently selected gym.
final currentGymTrainerClientsProvider =
    FutureProvider.autoDispose<List<TrainerClient>>((ref) {
  final gymId = ref.watch(currentGymIdProvider);
  if (gymId == null) throw _noGym();
  return ref.watch(trainerDashboardServiceProvider).getClients(gymId);
});

/// Explicit-gym variant of [currentGymTrainerClientsProvider].
final trainerClientsProvider =
    FutureProvider.autoDispose.family<List<TrainerClient>, String>((ref, gymId) {
  return ref.watch(trainerDashboardServiceProvider).getClients(gymId);
});

/// `GET /gyms/:gymId/trainer/analytics` for the currently selected gym.
final currentGymTrainerAnalyticsProvider =
    FutureProvider.autoDispose<TrainerAnalytics>((ref) {
  final gymId = ref.watch(currentGymIdProvider);
  if (gymId == null) throw _noGym();
  return ref.watch(trainerAnalyticsServiceProvider).getAnalytics(gymId);
});

/// Explicit-gym variant of [currentGymTrainerAnalyticsProvider].
final trainerAnalyticsProvider =
    FutureProvider.autoDispose.family<TrainerAnalytics, String>((ref, gymId) {
  return ref.watch(trainerAnalyticsServiceProvider).getAnalytics(gymId);
});

// ── Member-scoped reads (gymId, userId) ─────────────────────────────────────

final memberProfileProvider =
    FutureProvider.autoDispose.family<MemberProfile, ({String gymId, String userId})>(
        (ref, key) {
  return ref.watch(memberManagementServiceProvider)
      .getMemberProfile(key.gymId, key.userId);
});

final memberAttendanceProvider = FutureProvider.autoDispose
    .family<List<MemberAttendanceEntry>, ({String gymId, String userId})>(
        (ref, key) {
  return ref.watch(memberManagementServiceProvider)
      .getMemberAttendance(key.gymId, key.userId);
});

final memberWorkoutLogsProvider = FutureProvider.autoDispose
    .family<List<WorkoutLog>, ({String gymId, String userId})>((ref, key) {
  return ref.watch(memberManagementServiceProvider)
      .getMemberWorkoutLogs(key.gymId, key.userId);
});

final memberNutritionLogsProvider = FutureProvider.autoDispose
    .family<List<NutritionLog>, ({String gymId, String userId})>((ref, key) {
  return ref.watch(memberManagementServiceProvider)
      .getMemberNutritionLogs(key.gymId, key.userId);
});

final memberProgressEntriesProvider = FutureProvider.autoDispose
    .family<List<ProgressEntry>, ({String gymId, String userId})>((ref, key) {
  return ref.watch(memberManagementServiceProvider)
      .getMemberProgressEntries(key.gymId, key.userId);
});

final memberProgressSummaryProvider = FutureProvider.autoDispose
    .family<MemberProgressSummary, ({String gymId, String userId})>((ref, key) {
  return ref.watch(memberManagementServiceProvider)
      .getMemberProgressSummary(key.gymId, key.userId);
});

/// A member's current (non-archived) workout plans, newest first — used to
/// decide create-vs-update in the plan editor and to show real targets.
final memberWorkoutPlansProvider = FutureProvider.autoDispose
    .family<List<WorkoutPlan>, ({String gymId, String userId})>((ref, key) {
  return ref.watch(workoutPlanServiceProvider).getWorkoutPlans(key.gymId, memberId: key.userId);
});

/// A member's current (non-archived) diet plans, newest first.
final memberDietPlansProvider = FutureProvider.autoDispose
    .family<List<DietPlan>, ({String gymId, String userId})>((ref, key) {
  return ref.watch(dietPlanServiceProvider).getDietPlans(key.gymId, memberId: key.userId);
});

// ── Exercise library ────────────────────────────────────────────────────────

final exercisesProvider = FutureProvider.autoDispose.family<
    List<Exercise>, ({String? search, String? category, String? equipment})>(
    (ref, query) {
  return ref.watch(workoutPlanServiceProvider).getExercises(
        search: query.search,
        category: query.category,
        equipment: query.equipment,
      );
});

// ── Chat (REST reads) ───────────────────────────────────────────────────────

final chatThreadsProvider =
    FutureProvider.autoDispose.family<List<ChatThread>, String>((ref, gymId) {
  return ref.watch(chatServiceProvider).getThreads(gymId);
});

final chatMessagesProvider = FutureProvider.autoDispose
    .family<List<ChatMessage>, ({String gymId, String threadId})>((ref, key) {
  return ref.watch(chatServiceProvider).getMessages(key.gymId, key.threadId);
});