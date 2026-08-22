class WeightHistoryPoint {
  final String date;
  final double weightKg;

  const WeightHistoryPoint({required this.date, required this.weightKg});

  factory WeightHistoryPoint.fromJson(Map<String, dynamic> json) {
    return WeightHistoryPoint(
      date: json['date'] as String? ?? '',
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
    );
  }
}

class WeightSummary {
  final double? currentKg;
  final double? startKg;
  final double? targetKg;
  final List<WeightHistoryPoint> history;

  const WeightSummary({
    this.currentKg,
    this.startKg,
    this.targetKg,
    this.history = const [],
  });

  factory WeightSummary.fromJson(Map<String, dynamic> json) {
    return WeightSummary(
      currentKg: (json['currentKg'] as num?)?.toDouble(),
      startKg: (json['startKg'] as num?)?.toDouble(),
      targetKg: (json['targetKg'] as num?)?.toDouble(),
      history: (json['history'] as List? ?? [])
          .whereType<Map>()
          .map((e) => WeightHistoryPoint.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class ActivitySummary {
  final int workoutsCompleted;
  final double totalVolumeKg;
  final double consistencyRatePercent;
  final int? activeMinutes;

  const ActivitySummary({
    this.workoutsCompleted = 0,
    this.totalVolumeKg = 0,
    this.consistencyRatePercent = 0,
    this.activeMinutes,
  });

  factory ActivitySummary.fromJson(Map<String, dynamic> json) {
    return ActivitySummary(
      workoutsCompleted: (json['workoutsCompleted'] as num?)?.toInt() ?? 0,
      totalVolumeKg: (json['totalVolumeKg'] as num?)?.toDouble() ?? 0,
      consistencyRatePercent:
          (json['consistencyRatePercent'] as num?)?.toDouble() ?? 0,
      activeMinutes: (json['activeMinutes'] as num?)?.toInt(),
    );
  }
}

/// From `GET /members/me/analytics/summary`.
class AnalyticsSummary {
  final String range;
  final WeightSummary weight;
  final dynamic measurements;
  final List<double> hydration7Days;
  final ActivitySummary activity;

  const AnalyticsSummary({
    this.range = 'month',
    this.weight = const WeightSummary(),
    this.measurements,
    this.hydration7Days = const [],
    this.activity = const ActivitySummary(),
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      range: json['range'] as String? ?? 'month',
      weight: WeightSummary.fromJson(
        Map<String, dynamic>.from(json['weight'] as Map? ?? const {}),
      ),
      measurements: json['measurements'],
      hydration7Days: (json['hydration7Days'] as List? ?? [])
          .map((e) => (e as num?)?.toDouble() ?? 0)
          .toList(),
      activity: ActivitySummary.fromJson(
        Map<String, dynamic>.from(json['activity'] as Map? ?? const {}),
      ),
    );
  }
}
