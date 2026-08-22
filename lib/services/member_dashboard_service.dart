import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_summary.dart';
import '../models/daily_task.dart';
import '../models/dashboard_today.dart';
import '../models/diet_today.dart';
import '../models/member_notification.dart';
import '../models/workout_today.dart';
import 'api_client.dart';
import 'api_data.dart';

/// Member dashboard API — daily loop, analytics, notifications.
class MemberDashboardService {
  final Dio dio;
  MemberDashboardService(this.dio);

  Future<DashboardToday> getToday({String? date}) async {
    final res = await dio.get(
      '/members/me/dashboard/today',
      queryParameters: {if (date != null) 'date': date},
    );
    return DashboardToday.fromJson(asMap(res.data));
  }

  Future<WaterMetric> logWater({
    required double amountLiters,
    bool replace = false,
    String? date,
  }) async {
    final res = await dio.post('/members/me/logs/water', data: {
      'amountLiters': amountLiters,
      'replace': replace,
      if (date != null) 'date': date,
    });
    return WaterMetric.fromJson(asMap(res.data));
  }

  Future<StepsMetric> logSteps({
    required int steps,
    bool replace = false,
    String? date,
  }) async {
    final res = await dio.post('/members/me/logs/steps', data: {
      'steps': steps,
      if (replace) 'replace': true,
      if (date != null) 'date': date,
    });
    return StepsMetric.fromJson(asMap(res.data));
  }

  Future<List<DailyTask>> getTasks({String? date}) async {
    final res = await dio.get(
      '/members/me/tasks',
      queryParameters: {if (date != null) 'date': date},
    );
    return extractList(res.data)
        .whereType<Map>()
        .map((e) => DailyTask.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<DailyTaskCompletion> toggleTask(
    String taskId, {
    required bool completed,
    String? date,
  }) async {
    final res = await dio.patch(
      '/members/me/tasks/$taskId',
      data: {'completed': completed},
      queryParameters: {if (date != null) 'date': date},
    );
    return DailyTaskCompletion.fromJson(asMap(res.data));
  }

  Future<WorkoutToday> getWorkoutToday({String? date}) async {
    final res = await dio.get(
      '/members/me/workout/today',
      queryParameters: {if (date != null) 'date': date},
    );
    return WorkoutToday.fromJson(asMap(res.data));
  }

  Future<DietToday> getDietToday({String? date}) async {
    final res = await dio.get(
      '/members/me/diet/today',
      queryParameters: {if (date != null) 'date': date},
    );
    return DietToday.fromJson(asMap(res.data));
  }

  Future<DietMealCheckResult> checkMeal(
    String mealId, {
    required bool checked,
    String? date,
  }) async {
    final res = await dio.patch(
      '/members/me/diet/meals/$mealId/check',
      data: {
        'checked': checked,
        if (date != null) 'date': date,
      },
    );
    return DietMealCheckResult.fromJson(asMap(res.data));
  }

  Future<AnalyticsSummary> getAnalyticsSummary({
    String range = 'month',
  }) async {
    final res = await dio.get(
      '/members/me/analytics/summary',
      queryParameters: {'range': range},
    );
    return AnalyticsSummary.fromJson(asMap(res.data));
  }

  /// Raw CSV body — endpoint bypasses the JSON envelope.
  Future<String> exportAnalyticsCsv({String? month}) async {
    final res = await dio.get<String>(
      '/members/me/analytics/export',
      queryParameters: {
        'format': 'csv',
        if (month != null) 'month': month,
      },
      options: Options(responseType: ResponseType.plain),
    );
    return res.data ?? '';
  }

  Future<MemberNotificationPage> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await dio.get(
      '/members/me/notifications',
      queryParameters: {'page': page, 'limit': limit},
    );
    return MemberNotificationPage.fromJson(asMap(res.data));
  }

  Future<MemberNotification> markNotificationRead(String logId) async {
    final res = await dio.post('/members/me/notifications/$logId/read');
    return MemberNotification.fromJson(asMap(res.data));
  }
}

final memberDashboardServiceProvider = Provider<MemberDashboardService>((ref) {
  return MemberDashboardService(ref.watch(dioProvider));
});
