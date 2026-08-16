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

  /// `POST /gyms/:gymId/diet-plans`. Omit [memberId] to save a reusable
  /// template; assignment is a separate call ([assignDietPlan]).
  Future<DietPlan> createDietPlan(
    String gymId, {
    required String title,
    String? description,
    String? memberId,
    String? status,
    required List<Meal> meals,
  }) =>
      apiCall(() async {
        final plan = DietPlan(
          id: '',
          title: title,
          description: description,
          status: status ?? 'DRAFT',
          meals: meals,
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
  }) =>
      apiCall(() async {
        final plan = DietPlan(
          id: planId,
          title: title,
          description: description,
          status: status ?? 'DRAFT',
          meals: meals,
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