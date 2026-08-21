import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diet_plan.dart';
import 'api_client.dart';
import 'api_data.dart';
import 'api_failure.dart';

/// § Diet plan management.
///
/// Food items are freeform (`foodName` + manually entered macros) — no food
/// database. Plan edits replace the whole `meals[]` tree; the repository always
/// sends the complete structure ([DietPlan.toUpdatePayload]), never a delta.
class DietPlanService {
  final Dio dio;
  DietPlanService(this.dio);

  /// `GET /gyms/:gymId/diet-plans` — filterable by [memberId]/[status]; used
  /// to find a member's current plan before deciding create vs. update.
  Future<List<DietPlan>> getDietPlans(
    String gymId, {
    String? memberId,
    String? status,
  }) =>
      apiCall(() async {
        final query = <String, dynamic>{
          if (memberId != null) 'memberId': memberId,
          if (status != null) 'status': status,
        };
        final res = await dio.get('/gyms/$gymId/diet-plans', queryParameters: query);
        return extractList(res.data)
            .whereType<Map>()
            .map((e) => DietPlan.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });

  /// `POST /gyms/:gymId/diet-plans`. Omit [memberId] to save a reusable
  /// template; assignment is a separate call ([assignDietPlan]).
  Future<DietPlan> createDietPlan(
    String gymId, {
    required String title,
    String? description,
    String? memberId,
    String? status,
    required List<Meal> meals,
    double? dailyCalorieTarget,
    double? dailyProteinTargetG,
    double? dailyCarbsTargetG,
    double? dailyFatTargetG,
  }) =>
      apiCall(() async {
        final plan = DietPlan(
          id: '',
          title: title,
          description: description,
          status: status ?? 'DRAFT',
          meals: meals,
          dailyCalorieTarget: dailyCalorieTarget,
          dailyProteinTargetG: dailyProteinTargetG,
          dailyCarbsTargetG: dailyCarbsTargetG,
          dailyFatTargetG: dailyFatTargetG,
        );
        final res =
            await dio.post('/gyms/$gymId/diet-plans', data: plan.toCreatePayload(memberId: memberId));
        return DietPlan.fromJson(asMap(res.data));
      });

  /// `PATCH /gyms/:gymId/diet-plans/:id` — sends the complete [meals] tree,
  /// replacing the previous meal/item structure wholesale (no diffing).
  Future<DietPlan> updateDietPlan(
    String gymId,
    String planId, {
    String? title,
    String? description,
    String? status,
    required List<Meal> meals,
    double? dailyCalorieTarget,
    double? dailyProteinTargetG,
    double? dailyCarbsTargetG,
    double? dailyFatTargetG,
  }) =>
      apiCall(() async {
        final plan = DietPlan(
          id: planId,
          title: title,
          description: description,
          status: status ?? 'DRAFT',
          meals: meals,
          dailyCalorieTarget: dailyCalorieTarget,
          dailyProteinTargetG: dailyProteinTargetG,
          dailyCarbsTargetG: dailyCarbsTargetG,
          dailyFatTargetG: dailyFatTargetG,
        );
        final res =
            await dio.patch('/gyms/$gymId/diet-plans/$planId', data: plan.toUpdatePayload());
        return DietPlan.fromJson(asMap(res.data));
      });

  /// `POST /gyms/:gymId/diet-plans/:id/assign` — `{ memberId, startDate? }`.
  Future<void> assignDietPlan(
    String gymId,
    String planId, {
    required String memberId,
    String? startDate,
  }) =>
      apiCall(() async {
        await dio.post('/gyms/$gymId/diet-plans/$planId/assign', data: {
          'memberId': memberId,
          if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
        });
      });
}

/// Riverpod provider for [DietPlanService].
final dietPlanServiceProvider = Provider<DietPlanService>((ref) {
  return DietPlanService(ref.watch(dioProvider));
});