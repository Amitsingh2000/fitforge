import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/diet_plan.dart';
import '../../models/trainer_client.dart';
import '../../models/workout_plan.dart';
import '../../providers/gym_provider.dart';
import '../../services/api_failure.dart';
import '../../services/diet_plan_service.dart';
import '../../services/workout_plan_service.dart';
import '../../theme/app_theme.dart';
import '../../onboarding/widgets/primary_button.dart';
import '../../dashboard/widgets/state_views.dart';

class TrainerPlanEditorSheet extends ConsumerStatefulWidget {
  final TrainerClient client;

  const TrainerPlanEditorSheet({super.key, required this.client});

  @override
  ConsumerState<TrainerPlanEditorSheet> createState() =>
      _TrainerPlanEditorSheetState();
}

class _TrainerPlanEditorSheetState extends ConsumerState<TrainerPlanEditorSheet> {
  bool _isWorkoutSelected = true;
  bool _saving = false;

  // Controllers for Workout Plan
  final List<Map<String, String>> _exercises = [
    {'name': 'Barbell Squats', 'sets': '4', 'reps': '8-10'},
    {'name': 'Incline Bench Press', 'sets': '3', 'reps': '10-12'},
    {'name': 'Lat Pulldowns', 'sets': '4', 'reps': '10'},
    {'name': 'Plank Hold', 'sets': '3', 'reps': '60s'},
  ];

  // Controllers for Meal Plan
  final List<Map<String, String>> _meals = [
    {'name': 'Oats & Whey Protein', 'time': '8:00 AM', 'calories': '520 kcal'},
    {'name': 'Grilled Chicken & Rice', 'time': '1:00 PM', 'calories': '680 kcal'},
    {'name': 'Greek Yogurt & Almonds', 'time': '4:30 PM', 'calories': '250 kcal'},
    {'name': 'Baked Salmon & Broccoli', 'time': '8:00 PM', 'calories': '650 kcal'},
  ];

  final _newExerciseName = TextEditingController();
  final _newExerciseSets = TextEditingController();
  final _newExerciseReps = TextEditingController();

  final _newMealName = TextEditingController();
  final _newMealTime = TextEditingController();
  final _newMealCalories = TextEditingController();

  @override
  void dispose() {
    _newExerciseName.dispose();
    _newExerciseSets.dispose();
    _newExerciseReps.dispose();
    _newMealName.dispose();
    _newMealTime.dispose();
    _newMealCalories.dispose();
    super.dispose();
  }

  double _parseCalories(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(digits) ?? 0;
  }

  Future<void> _save() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null || _saving) return;
    setState(() => _saving = true);

    void showError(Object e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.bgTertiary,
          content: Text(
            'Could not save plan: ${friendlyApiError(e)}',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentCoral),
          ),
        ),
      );
      setState(() => _saving = false);
    }

    try {
      if (_isWorkoutSelected) {
        final days = [
          WorkoutDay(
            dayNumber: 1,
            label: 'Day 1',
            exercises: _exercises
                .map((e) => WorkoutPlanExercise(
                      name: e['name']!,
                      sets: int.tryParse(e['sets'] ?? ''),
                      reps: int.tryParse((e['reps'] ?? '').split('-').first),
                    ))
                .toList(),
          ),
        ];
        final plan = await ref
            .read(workoutPlanServiceProvider)
            .createWorkoutPlan(
              gymId,
              title: 'Custom Workout Plan',
              status: 'ACTIVE',
              memberId: widget.client.userId,
              days: days,
            );
        await ref
            .read(workoutPlanServiceProvider)
            .assignWorkoutPlan(gymId, plan.id, memberId: widget.client.userId);
      } else {
        final meals = _meals
            .map((m) => Meal(
                  name: m['name']!,
                  time: m['time'],
                  targetCalories: _parseCalories(m['calories'] ?? ''),
                  items: [
                    FoodItem(
                      foodName: m['name']!,
                      calories: _parseCalories(m['calories'] ?? ''),
                    ),
                  ],
                ))
            .toList();
        final plan = await ref.read(dietPlanServiceProvider).createDietPlan(
              gymId,
              title: 'Custom Diet Plan',
              status: 'ACTIVE',
              memberId: widget.client.userId,
              meals: meals,
            );
        await ref
            .read(dietPlanServiceProvider)
            .assignDietPlan(gymId, plan.id, memberId: widget.client.userId);
      }

      if (mounted) Navigator.of(context).pop(true);
    } on ApiFailure catch (e) {
      showError(e);
    } on Object catch (e) {
      showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Update Plan',
                style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                widget.client.fullName,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Segmented Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isWorkoutSelected = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isWorkoutSelected
                            ? AppColors.accentCyan.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: _isWorkoutSelected
                            ? Border.all(color: AppColors.accentCyan.withValues(alpha: 0.4))
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          'Workout Plan',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: _isWorkoutSelected ? AppColors.accentCyan : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isWorkoutSelected = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isWorkoutSelected
                            ? AppColors.accentCyan.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: !_isWorkoutSelected
                            ? Border.all(color: AppColors.accentCyan.withValues(alpha: 0.4))
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          'Meal Plan',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: !_isWorkoutSelected ? AppColors.accentCyan : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Main list content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _isWorkoutSelected ? _buildWorkoutFields() : _buildMealFields(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Button
          PrimaryButton(
            label: _saving ? 'Saving plan…' : 'Save & Update Plan',
            isEnabled: !_saving,
            onTap: _save,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWorkoutFields() {
    return [
      Text('Current Exercises', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ...List.generate(_exercises.length, (index) {
        final exercise = _exercises[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise['name']!,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${exercise['sets']} Sets x ${exercise['reps']} Reps',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _saving
                    ? null
                    : () {
                        setState(() {
                          _exercises.removeAt(index);
                        });
                      },
                child: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.accentCoral, size: 20),
              ),
            ],
          ),
        );
      }),
      const SizedBox(height: 16),
      Text('Add New Exercise', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      TextField(
        controller: _newExerciseName,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        decoration: _getInputDecoration('Exercise Name (e.g. Deadlifts)'),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newExerciseSets,
              keyboardType: TextInputType.number,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: _getInputDecoration('Sets (e.g. 4)'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _newExerciseReps,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: _getInputDecoration('Reps (e.g. 8-12)'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: _saving
              ? null
              : () {
                  if (_newExerciseName.text.isNotEmpty) {
                    setState(() {
                      _exercises.add({
                        'name': _newExerciseName.text,
                        'sets': _newExerciseSets.text.isEmpty ? '3' : _newExerciseSets.text,
                        'reps': _newExerciseReps.text.isEmpty ? '10' : _newExerciseReps.text,
                      });
                      _newExerciseName.clear();
                      _newExerciseSets.clear();
                      _newExerciseReps.clear();
                    });
                  }
                },
          icon: const Icon(Icons.add_rounded, color: AppColors.accentCyan, size: 18),
          label: Text('Add Exercise', style: AppTextStyles.caption.copyWith(color: AppColors.accentCyan, fontWeight: FontWeight.bold)),
        ),
      ),
    ];
  }

  List<Widget> _buildMealFields() {
    return [
      Text('Current Meal Plan', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ...List.generate(_meals.length, (index) {
        final meal = _meals[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal['name']!,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${meal['time']} | ${meal['calories']}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _saving
                    ? null
                    : () {
                        setState(() {
                          _meals.removeAt(index);
                        });
                      },
                child: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.accentCoral, size: 20),
              ),
            ],
          ),
        );
      }),
      const SizedBox(height: 16),
      Text('Add New Meal', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      TextField(
        controller: _newMealName,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        decoration: _getInputDecoration('Meal Name (e.g. Scrambled Eggs)'),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newMealTime,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: _getInputDecoration('Time (e.g. 7:30 AM)'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _newMealCalories,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: _getInputDecoration('Calories (e.g. 400 kcal)'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: _saving
              ? null
              : () {
                  if (_newMealName.text.isNotEmpty) {
                    setState(() {
                      _meals.add({
                        'name': _newMealName.text,
                        'time': _newMealTime.text.isEmpty ? '12:00 PM' : _newMealTime.text,
                        'calories': _newMealCalories.text.isEmpty ? '300 kcal' : _newMealCalories.text,
                      });
                      _newMealName.clear();
                      _newMealTime.clear();
                      _newMealCalories.clear();
                    });
                  }
                },
          icon: const Icon(Icons.add_rounded, color: AppColors.accentCyan, size: 18),
          label: Text('Add Meal', style: AppTextStyles.caption.copyWith(color: AppColors.accentCyan, fontWeight: FontWeight.bold)),
        ),
      ),
    ];
  }

  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
      filled: true,
      fillColor: AppColors.bgPrimary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentCyan, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}