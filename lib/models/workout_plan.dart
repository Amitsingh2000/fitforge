/// A workout plan from `POST/PATCH /gyms/:gymId/workout-plans[/:id]`.
///
/// A plan is a flat ordered list of days (`dayNumber`), not a week×day matrix —
/// the trainer's `label` text ("Week 1 Day 1") carries any grouping.
///
/// ⚠️ PATCH semantics: sending `days[]` **replaces the entire day/exercise
/// tree** (no partial diffing). `toCreatePayload()`/`toUpdatePayload()` always
/// emit the complete current structure — never a delta.
class WorkoutPlan {
  final String id;
  final String? gymId;
  final String? memberId;

  /// DRAFT (authored, pending) / ACTIVE (assigned) / COMPLETED.
  final String status;
  final String? title;
  final String? description;
  final DateTime? createdAt;
  final List<WorkoutDay> days;

  const WorkoutPlan({
    required this.id,
    this.gymId,
    this.memberId,
    this.status = 'DRAFT',
    this.title,
    this.description,
    this.createdAt,
    this.days = const [],
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'] as List? ?? json['daysList'] as List?;
    return WorkoutPlan(
      id: json['id'] as String? ?? '',
      gymId: json['gymId'] as String?,
      memberId: json['memberId'] as String?,
      status: json['status'] as String? ?? 'DRAFT',
      title: json['title'] as String? ?? json['name'] as String?,
      description: json['description'] as String?,
      createdAt: _date(json['createdAt']),
      days: (rawDays ?? [])
          .whereType<Map>()
          .map((e) => WorkoutDay.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  /// Body for `POST /gyms/:gymId/workout-plans`. Omit [memberId] to save the
  /// plan as a reusable template (no assignment).
  Map<String, dynamic> toCreatePayload({String? memberId}) {
    return {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (memberId != null) 'memberId': memberId,
      'days': days.map((d) => d.toJson()).toList(),
    };
  }

  /// Body for `PATCH /gyms/:gymId/workout-plans/:id` — sends the complete
  /// days[] tree so it replaces the old one wholesale.
  Map<String, dynamic> toUpdatePayload() {
    return {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      'status': status,
      'days': days.map((d) => d.toJson()).toList(),
    };
  }

  static DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;
}

/// One day inside a [WorkoutPlan].
class WorkoutDay {
  final int dayNumber;
  final String? label;
  final String? note;
  final List<WorkoutPlanExercise> exercises;

  const WorkoutDay({
    required this.dayNumber,
    this.label,
    this.note,
    this.exercises = const [],
  });

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    final rawExercises = json['exercises'] as List? ?? json['items'] as List?;
    return WorkoutDay(
      dayNumber: (json['dayNumber'] as num?)?.toInt() ?? 0,
      label: json['label'] as String?,
      note: json['note'] as String?,
      exercises: (rawExercises ?? [])
          .whereType<Map>()
          .map((e) =>
              WorkoutPlanExercise.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      if (label != null) 'label': label,
      if (note != null) 'note': note,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

/// An exercise prescription inside a [WorkoutDay].
class WorkoutPlanExercise {
  final String? exerciseId;
  final String name;
  final int order;
  final int? sets;
  final String? reps;
  final double? restSeconds;
  final double? weightKg;

  const WorkoutPlanExercise({
    this.exerciseId,
    required this.name,
    this.order = 0,
    this.sets,
    this.reps,
    this.restSeconds,
    this.weightKg,
  });

  factory WorkoutPlanExercise.fromJson(Map<String, dynamic> json) {
    final rawReps = json['reps'];
    return WorkoutPlanExercise(
      exerciseId: json['exerciseId'] as String?,
      name: json['name'] as String? ??
          json['exerciseName'] as String? ??
          json['exercise']?['name'] as String? ??
          '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      sets: (json['sets'] as num?)?.toInt(),
      reps: rawReps == null ? null : rawReps.toString(),
      restSeconds: (json['restSeconds'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'order': order,
      'sets': sets ?? 1,
      'reps': reps ?? '8-12',
      if (restSeconds != null) 'restSeconds': restSeconds?.round(),
    };
  }
}