import 'daily_task.dart';

class MetricPair {
  final num current;
  final num target;

  const MetricPair({this.current = 0, this.target = 0});

  factory MetricPair.fromJson(Map<String, dynamic> json, {String currentKey = 'current', String targetKey = 'target'}) {
    return MetricPair(
      current: json[currentKey] as num? ?? 0,
      target: json[targetKey] as num? ?? 0,
    );
  }
}

class CalorieMetric {
  final int consumed;
  final int target;

  const CalorieMetric({this.consumed = 0, this.target = 0});

  factory CalorieMetric.fromJson(Map<String, dynamic> json) {
    return CalorieMetric(
      consumed: (json['consumed'] as num?)?.toInt() ?? 0,
      target: (json['target'] as num?)?.toInt() ?? 0,
    );
  }
}

class WaterMetric {
  final double currentLiters;
  final double targetLiters;

  const WaterMetric({this.currentLiters = 0, this.targetLiters = 4});

  factory WaterMetric.fromJson(Map<String, dynamic> json) {
    return WaterMetric(
      currentLiters: (json['currentLiters'] as num?)?.toDouble() ?? 0,
      targetLiters: (json['targetLiters'] as num?)?.toDouble() ?? 4,
    );
  }
}

class StepsMetric {
  final int current;
  final int target;

  const StepsMetric({this.current = 0, this.target = 10000});

  factory StepsMetric.fromJson(Map<String, dynamic> json) {
    return StepsMetric(
      current: (json['current'] as num?)?.toInt() ?? 0,
      target: (json['target'] as num?)?.toInt() ?? 10000,
    );
  }
}

class TodayWorkoutSummary {
  final String id;
  final String title;
  final int? durationMinutes;
  final int? estimatedCalories;
  final bool isCompleted;
  final String planId;
  final String dayId;
  final int dayNumber;

  const TodayWorkoutSummary({
    required this.id,
    required this.title,
    this.durationMinutes,
    this.estimatedCalories,
    this.isCompleted = false,
    required this.planId,
    required this.dayId,
    this.dayNumber = 1,
  });

  factory TodayWorkoutSummary.fromJson(Map<String, dynamic> json) {
    return TodayWorkoutSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      estimatedCalories: (json['estimatedCalories'] as num?)?.toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      planId: json['planId'] as String? ?? '',
      dayId: json['dayId'] as String? ?? '',
      dayNumber: (json['dayNumber'] as num?)?.toInt() ?? 1,
    );
  }
}

/// Aggregate from `GET /members/me/dashboard/today`.
class DashboardToday {
  final String date;
  final int streakDays;
  final CalorieMetric calories;
  final WaterMetric water;
  final StepsMetric steps;
  final List<DailyTask> tasks;
  final TodayWorkoutSummary? todayWorkout;
  final int unreadNotifications;

  const DashboardToday({
    required this.date,
    this.streakDays = 0,
    this.calories = const CalorieMetric(),
    this.water = const WaterMetric(),
    this.steps = const StepsMetric(),
    this.tasks = const [],
    this.todayWorkout,
    this.unreadNotifications = 0,
  });

  factory DashboardToday.fromJson(Map<String, dynamic> json) {
    return DashboardToday(
      date: json['date'] as String? ?? '',
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      calories: CalorieMetric.fromJson(
        Map<String, dynamic>.from(json['calories'] as Map? ?? const {}),
      ),
      water: WaterMetric.fromJson(
        Map<String, dynamic>.from(json['water'] as Map? ?? const {}),
      ),
      steps: StepsMetric.fromJson(
        Map<String, dynamic>.from(json['steps'] as Map? ?? const {}),
      ),
      tasks: (json['tasks'] as List? ?? [])
          .whereType<Map>()
          .map((e) => DailyTask.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      todayWorkout: json['todayWorkout'] is Map
          ? TodayWorkoutSummary.fromJson(
              Map<String, dynamic>.from(json['todayWorkout'] as Map),
            )
          : null,
      unreadNotifications: (json['unreadNotifications'] as num?)?.toInt() ?? 0,
    );
  }
}
