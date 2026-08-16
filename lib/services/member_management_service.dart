import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/member_attendance.dart';
import '../models/member_profile.dart';
import '../models/member_progress_summary.dart';
import '../models/nutrition_log.dart';
import '../models/progress_entry.dart';
import '../models/workout_log.dart';
import 'api_client.dart';
import 'api_data.dart';
import 'api_failure.dart';

/// § Member management — the six per-member reads plus the progress summary.
///
/// All reads are server-scoped for trainers (`assertCanAccessMember`): a
/// TRAINER only sees members actually assigned to them. Handle a 403 as "not
/// your member", don't filter client-side.
class MemberManagementService {
  final Dio dio;
  MemberManagementService(this.dio);

  /// `GET /gyms/:gymId/members/:userId/profile` — goal, dietary preference,
  /// injuries, etc. (the member's goal-intake profile).
  Future<MemberProfile> getMemberProfile(String gymId, String userId) =>
      apiCall(() async {
        final res = await dio.get('/gyms/$gymId/members/$userId/profile');
        return MemberProfile.fromJson(asMap(res.data));
      });

  /// `GET /gyms/:gymId/members/:userId/attendance`.
  Future<List<MemberAttendanceEntry>> getMemberAttendance(
          String gymId, String userId) =>
      apiCall(() async {
        final res = await dio.get('/gyms/$gymId/members/$userId/attendance');
        return extractList(res.data)
            .whereType<Map>()
            .map((e) =>
                MemberAttendanceEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });

  /// `GET /gyms/:gymId/members/:userId/workout-logs` — raw sets/reps/weight per
  /// exercise in each logged workout.
  Future<List<WorkoutLog>> getMemberWorkoutLogs(String gymId, String userId) =>
      apiCall(() async {
        final res = await dio.get('/gyms/$gymId/members/$userId/workout-logs');
        return extractList(res.data)
            .whereType<Map>()
            .map((e) => WorkoutLog.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });

  /// `GET /gyms/:gymId/members/:userId/nutrition-logs` — freeform foodName +
  /// manual macros.
  Future<List<NutritionLog>> getMemberNutritionLogs(
          String gymId, String userId) =>
      apiCall(() async {
        final res = await dio.get('/gyms/$gymId/members/$userId/nutrition-logs');
        return extractList(res.data)
            .whereType<Map>()
            .map((e) => NutritionLog.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });

  /// `GET /gyms/:gymId/members/:userId/progress-entries` — weight /
  /// measurements / progress photos.
  Future<List<ProgressEntry>> getMemberProgressEntries(
          String gymId, String userId) =>
      apiCall(() async {
        final res = await dio.get('/gyms/$gymId/members/$userId/progress-entries');
        return extractList(res.data)
            .whereType<Map>()
            .map((e) => ProgressEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });

  /// `GET /gyms/:gymId/members/:userId/progress-summary` — workout completion,
  /// nutrition compliance, and the heuristic [GoalAchievement] verdict.
  Future<MemberProgressSummary> getMemberProgressSummary(
          String gymId, String userId) =>
      apiCall(() async {
        final res = await dio.get('/gyms/$gymId/members/$userId/progress-summary');
        return MemberProgressSummary.fromJson(asMap(res.data));
      });
}

/// Riverpod provider for [MemberManagementService].
final memberManagementServiceProvider =
    Provider<MemberManagementService>((ref) {
  return MemberManagementService(ref.watch(dioProvider));
});