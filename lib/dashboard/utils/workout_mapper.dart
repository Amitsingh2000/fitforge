import 'package:flutter/material.dart';
import '../../models/workout_today.dart';
import '../../theme/app_theme.dart';
import '../screens/exercise_detail_screen.dart';

WorkoutExercise mapWorkoutEntry(WorkoutExerciseEntry entry) {
  final ex = entry.exercise;
  final name = ex?.name ?? 'Exercise';
  final category = ex?.category ?? 'General';
  final reps = int.tryParse(entry.reps ?? '') ?? 10;

  return WorkoutExercise(
    name: name,
    detail: '$category • ${entry.sets ?? 0} sets',
    sets: entry.sets ?? 3,
    reps: reps,
    restSeconds: entry.restSeconds ?? 60,
    icon: Icons.fitness_center_rounded,
    color: AppColors.accentPurple,
    videoUrl: ex?.videoUrl,
    muscleGroup: category,
    difficulty: 'Intermediate',
    equipment: 'Gym',
    defaultWeight: 20,
    tempo: entry.tempo ?? '3-0-1-0',
    tips: entry.notes != null && entry.notes!.isNotEmpty
        ? [entry.notes!]
        : const [],
  );
}
