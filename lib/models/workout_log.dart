/// One logged workout from `GET /gyms/:gymId/members/:userId/workout-logs`.
///
/// Carries raw per-exercise sets/reps/weight so the trainer can review actual
/// performance, not just "was the day completed".
class WorkoutLog {
  final String id;
  final String? workoutPlanId;
  final int? dayNumber;

  /// Plan/day label, e.g. "Week 1 Day 1" if the trainer labelled it.
  final String? label;
  final DateTime? loggedAt;

  /// Completion flag if the backend tracks it.
  final bool completed;

  /// Status text when the log is still in progress (e.g. `STARTED`, `COMPLETED`).
  final String? status;

  final List<WorkoutLogSet> sets;

  const WorkoutLog({
    required this.id,
    this.workoutPlanId,
    this.dayNumber,
    this.label,
    this.loggedAt,
    this.completed = false,
    this.status,
    this.sets = const [],
  });

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    final rawSets = json['sets'] as List? ?? json['exercises'] as List?;
    return WorkoutLog(
      id: json['id'] as String? ?? '',
      workoutPlanId: json['workoutPlanId'] as String?,
      dayNumber: (json['dayNumber'] as num?)?.toInt(),
      label: json['label'] as String?,
      loggedAt: _date(json['loggedAt'] ?? json['performedAt'] ?? json['completedAt']),
      completed: json['completed'] as bool? ?? json['isCompleted'] as bool? ?? false,
      status: json['status'] as String?,
      sets: (rawSets ?? [])
          .whereType<Map>()
          .map((e) => WorkoutLogSet.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  static DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;
}

/// One exercise's logged performance inside a [WorkoutLog].
class WorkoutLogSet {
  final String exerciseName;
  final String? exerciseId;
  final int? setNumber;
  final int? reps;
  final double? weightKg;
  final bool completed;

  const WorkoutLogSet({
    required this.exerciseName,
    this.exerciseId,
    this.setNumber,
    this.reps,
    this.weightKg,
    this.completed = false,
  });

  factory WorkoutLogSet.fromJson(Map<String, dynamic> json) {
    final exerciseName = json['exerciseName'] as String? ??
        json['name'] as String? ??
        json['exercise']?['name'] as String? ??
        '';
    return WorkoutLogSet(
      exerciseName: exerciseName,
      exerciseId: json['exerciseId'] as String?,
      setNumber: (json['setNumber'] as num?)?.toInt() ?? (json['set'] as num?)?.toInt(),
      reps: (json['reps'] as num?)?.toInt(),
      weightKg: (json['weightKg'] as num?)?.toDouble() ??
          (json['weight'] as num?)?.toDouble(),
      completed: json['completed'] as bool? ?? false,
    );
  }
}