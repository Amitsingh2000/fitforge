class WorkoutExerciseInfo {
  final String id;
  final String name;
  final String? category;
  final String? videoUrl;

  const WorkoutExerciseInfo({
    required this.id,
    required this.name,
    this.category,
    this.videoUrl,
  });

  factory WorkoutExerciseInfo.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );
  }
}

class WorkoutExerciseEntry {
  final String id;
  final int order;
  final int? sets;
  final String? reps;
  final int? restSeconds;
  final String? tempo;
  final String? notes;
  final WorkoutExerciseInfo? exercise;

  const WorkoutExerciseEntry({
    required this.id,
    this.order = 0,
    this.sets,
    this.reps,
    this.restSeconds,
    this.tempo,
    this.notes,
    this.exercise,
  });

  factory WorkoutExerciseEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseEntry(
      id: json['id'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      sets: (json['sets'] as num?)?.toInt(),
      reps: json['reps'] as String?,
      restSeconds: (json['restSeconds'] as num?)?.toInt(),
      tempo: json['tempo'] as String?,
      notes: json['notes'] as String?,
      exercise: json['exercise'] is Map
          ? WorkoutExerciseInfo.fromJson(
              Map<String, dynamic>.from(json['exercise'] as Map),
            )
          : null,
    );
  }
}

class WorkoutDaySummary {
  final String id;
  final String title;
  final int? durationMinutes;
  final int? estimatedCalories;
  final bool isCompleted;
  final String planId;
  final String dayId;
  final int dayNumber;

  const WorkoutDaySummary({
    required this.id,
    required this.title,
    this.durationMinutes,
    this.estimatedCalories,
    this.isCompleted = false,
    required this.planId,
    required this.dayId,
    this.dayNumber = 1,
  });

  factory WorkoutDaySummary.fromJson(Map<String, dynamic> json) {
    return WorkoutDaySummary(
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

/// From `GET /members/me/workout/today`.
class WorkoutToday {
  final String date;
  final WorkoutDaySummary? workout;
  final List<WorkoutExerciseEntry> exercises;

  const WorkoutToday({
    required this.date,
    this.workout,
    this.exercises = const [],
  });

  factory WorkoutToday.fromJson(Map<String, dynamic> json) {
    return WorkoutToday(
      date: json['date'] as String? ?? '',
      workout: json['workout'] is Map
          ? WorkoutDaySummary.fromJson(
              Map<String, dynamic>.from(json['workout'] as Map),
            )
          : null,
      exercises: (json['exercises'] as List? ?? [])
          .whereType<Map>()
          .map((e) => WorkoutExerciseEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
