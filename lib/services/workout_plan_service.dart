import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';
import '../models/workout_plan.dart';
import 'api_client.dart';
import 'api_data.dart';
import 'api_failure.dart';

/// § Workout plan management + the platform exercise library.
///
/// Plan edits replace the whole `days[]` tree — the repository always sends the
/// complete structure built from [WorkoutPlan.toUpdatePayload], never a delta.
class WorkoutPlanService {
  final Dio dio;
  WorkoutPlanService(this.dio);

  /// `POST /gyms/:gymId/workout-plans`.
  ///
  /// Omit [memberId] to save the plan as a reusable template. Pass it to create
  /// the plan in context of a member; assignment is a separate call
  /// ([assignWorkoutPlan]).
  Future<WorkoutPlan> createWorkoutPlan(
    String gymId, {
    required String title,
    String? description,
    String? memberId,
    String? status,
    required List<WorkoutDay> days,
  }) =>
      apiCall(() async {
        final plan = WorkoutPlan(
          id: '',
          title: title,
          description: description,
          status: status ?? 'DRAFT',
          days: days,
        );
        final res =
            await dio.post('/gyms/$gymId/workout-plans', data: plan.toCreatePayload(memberId: memberId));
        return WorkoutPlan.fromJson(asMap(res.data));
      });

  /// `GET /gyms/:gymId/workout-plans` — filterable by [memberId]/[status];
  /// used to find a member's current plan before deciding create vs. update.
  Future<List<WorkoutPlan>> getWorkoutPlans(
    String gymId, {
    String? memberId,
    String? status,
  }) =>
      apiCall(() async {
        final query = <String, dynamic>{
          if (memberId != null) 'memberId': memberId,
          if (status != null) 'status': status,
        };
        final res = await dio.get('/gyms/$gymId/workout-plans', queryParameters: query);
        return extractList(res.data)
            .whereType<Map>()
            .map((e) => WorkoutPlan.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });

  /// `PATCH /gyms/:gymId/workout-plans/:id` — sends the complete [days] tree,
  /// replacing the previous day/exercise structure wholesale (no diffing).
  Future<WorkoutPlan> updateWorkoutPlan(
    String gymId,
    String planId, {
    String? title,
    String? description,
    String? status,
    required List<WorkoutDay> days,
  }) =>
      apiCall(() async {
        final plan = WorkoutPlan(
          id: planId,
          title: title,
          description: description,
          status: status ?? 'DRAFT',
          days: days,
        );
        final res =
            await dio.patch('/gyms/$gymId/workout-plans/$planId', data: plan.toUpdatePayload());
        return WorkoutPlan.fromJson(asMap(res.data));
      });

  /// `POST /gyms/:gymId/workout-plans/:id/assign` —
  /// `{ memberId, startDate? }`.
  Future<void> assignWorkoutPlan(
    String gymId,
    String planId, {
    required String memberId,
    String? startDate,
  }) =>
      apiCall(() async {
        await dio.post('/gyms/$gymId/workout-plans/$planId/assign', data: {
          'memberId': memberId,
          if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
        });
      });

  /// `GET /exercises` — platform-wide library, searchable by name/category/
  /// equipment. Trainers can also add custom exercises ([createExercise]).
  Future<List<Exercise>> getExercises({
    String? search,
    String? category,
    String? equipment,
  }) =>
      apiCall(() async {
        final query = <String, dynamic>{};
        if (search != null && search.isNotEmpty) query['search'] = search;
        if (category != null && category.isNotEmpty) query['category'] = category;
        if (equipment != null && equipment.isNotEmpty) query['equipment'] = equipment;

        final res = await dio.get('/exercises', queryParameters: query);
        return extractList(res.data)
            .whereType<Map>()
            .map((e) => Exercise.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });

  /// `POST /exercises` — add a trainer-authored custom exercise.
  Future<Exercise> createExercise({
    required String name,
    String? category,
    String? muscleGroup,
    String? equipment,
    String? description,
    String? difficulty,
  }) =>
      apiCall(() async {
        final exercise = Exercise(
          id: '',
          name: name,
          category: category,
          muscleGroup: muscleGroup,
          equipment: equipment,
          description: description,
          difficulty: difficulty,
          isCustom: true,
        );
        final res = await dio.post('/exercises', data: exercise.toJson());
        return Exercise.fromJson(asMap(res.data));
      });
}

/// Riverpod provider for [WorkoutPlanService].
final workoutPlanServiceProvider = Provider<WorkoutPlanService>((ref) {
  return WorkoutPlanService(ref.watch(dioProvider));
});