import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/exercise.dart';
import '../../models/diet_plan.dart';
import '../../models/trainer_client.dart';
import '../../models/workout_plan.dart';
import '../../providers/gym_provider.dart';
import '../../providers/trainer_flow_providers.dart';
import '../../services/api_failure.dart';
import '../../services/diet_plan_service.dart';
import '../../services/workout_plan_service.dart';
import '../../theme/app_theme.dart';
import '../../onboarding/widgets/primary_button.dart';
import '../../dashboard/widgets/state_views.dart';

/// Create-or-update editor for a client's workout/diet plan.
///
/// Loads the client's current (non-archived) plan of each type on open, so
/// the trainer edits real data instead of a blank/fake slate, and "Save"
/// PATCHes that plan's id when one exists instead of always POSTing a new
/// duplicate draft.
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
  bool _loadingExisting = true;
  String? _loadError;

  WorkoutPlan? _existingWorkoutPlan;
  DietPlan? _existingDietPlan;

  final List<Map<String, String>> _exercises = [];
  final List<Map<String, String>> _meals = [];

  final _calorieTarget = TextEditingController();
  final _proteinTarget = TextEditingController();
  final _carbsTarget = TextEditingController();
  final _fatTarget = TextEditingController();

  final _newExerciseName = TextEditingController();
  final _newExerciseSets = TextEditingController();
  final _newExerciseReps = TextEditingController();

  final _newMealName = TextEditingController();
  final _newMealTime = TextEditingController();
  final _newMealCalories = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
  }

  @override
  void dispose() {
    _calorieTarget.dispose();
    _proteinTarget.dispose();
    _carbsTarget.dispose();
    _fatTarget.dispose();
    _newExerciseName.dispose();
    _newExerciseSets.dispose();
    _newExerciseReps.dispose();
    _newMealName.dispose();
    _newMealTime.dispose();
    _newMealCalories.dispose();
    super.dispose();
  }

  /// A member can have at most one active editing target per type — pick the
  /// most recently created plan that isn't archived/completed.
  T? _pickCurrent<T>(List<T> plans, String Function(T) statusOf) {
    for (final p in plans) {
      final s = statusOf(p).toUpperCase();
      if (s != 'ARCHIVED' && s != 'COMPLETED') return p;
    }
    return null;
  }

  Future<void> _loadExisting() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) {
      setState(() {
        _loadingExisting = false;
        _loadError = 'No gym selected.';
      });
      return;
    }
    try {
      final results = await Future.wait([
        ref.read(workoutPlanServiceProvider).getWorkoutPlans(gymId, memberId: widget.client.userId),
        ref.read(dietPlanServiceProvider).getDietPlans(gymId, memberId: widget.client.userId),
      ]);
      final workoutPlans = results[0] as List<WorkoutPlan>;
      final dietPlans = results[1] as List<DietPlan>;
      final workout = _pickCurrent<WorkoutPlan>(workoutPlans, (p) => p.status);
      final diet = _pickCurrent<DietPlan>(dietPlans, (p) => p.status);

      if (!mounted) return;
      setState(() {
        _existingWorkoutPlan = workout;
        _existingDietPlan = diet;
        _exercises.addAll((workout?.days.isNotEmpty ?? false)
            ? workout!.days.first.exercises.map((e) => {
                  'name': e.name,
                  'sets': '${e.sets ?? 3}',
                  'reps': e.reps ?? '8-12',
                })
            : const []);
        _meals.addAll((diet?.meals ?? const []).map((m) {
          final item = m.items.isNotEmpty ? m.items.first : null;
          return {
            'name': item?.foodName ?? m.name,
            'time': item?.unit ?? '',
            'calories': item?.calories != null ? '${item!.calories!.round()} kcal' : '',
          };
        }));
        _calorieTarget.text = diet?.dailyCalorieTarget?.round().toString() ?? '';
        _proteinTarget.text = diet?.dailyProteinTargetG?.round().toString() ?? '';
        _carbsTarget.text = diet?.dailyCarbsTargetG?.round().toString() ?? '';
        _fatTarget.text = diet?.dailyFatTargetG?.round().toString() ?? '';
        _loadingExisting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingExisting = false;
        _loadError = friendlyApiError(e);
      });
    }
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
        final svc = ref.read(workoutPlanServiceProvider);
        final resolved = <WorkoutPlanExercise>[];
        for (var i = 0; i < _exercises.length; i++) {
          final row = _exercises[i];
          final name = row['name']!.trim();
          if (name.isEmpty) continue;
          final matches = await svc.getExercises(search: name);
          Exercise? existing;
          for (final e in matches) {
            if (e.name.toLowerCase() == name.toLowerCase()) {
              existing = e;
              break;
            }
          }
          final exercise = existing ??
              await svc.createExercise(name: name, category: 'General');
          resolved.add(WorkoutPlanExercise(
            exerciseId: exercise.id,
            name: name,
            order: resolved.length,
            sets: int.tryParse(row['sets'] ?? '') ?? 3,
            reps: row['reps'] ?? '8-12',
          ));
        }
        if (resolved.isEmpty) {
          throw const ApiFailure(
            kind: ApiFailureKind.validation,
            message: 'Add at least one exercise.',
          );
        }
        final days = [WorkoutDay(dayNumber: 1, label: 'Day 1', exercises: resolved)];
        final existing = _existingWorkoutPlan;
        if (existing != null && existing.id.isNotEmpty) {
          await svc.updateWorkoutPlan(gymId, existing.id, title: existing.title, days: days);
        } else {
          await svc.createWorkoutPlan(
            gymId,
            title: 'Plan for ${widget.client.fullName}',
            memberId: widget.client.userId,
            days: days,
          );
        }
      } else {
        final meals = <Meal>[];
        for (var i = 0; i < _meals.length; i++) {
          final row = _meals[i];
          final name = row['name']!.trim();
          if (name.isEmpty) continue;
          meals.add(Meal(
            name: name,
            order: meals.length,
            items: [
              FoodItem(
                foodName: name,
                calories: _parseCalories(row['calories'] ?? ''),
                unit: row['time'],
              ),
            ],
          ));
        }
        if (meals.isEmpty) {
          throw const ApiFailure(
            kind: ApiFailureKind.validation,
            message: 'Add at least one meal.',
          );
        }
        final svc = ref.read(dietPlanServiceProvider);
        final calorieTarget = double.tryParse(_calorieTarget.text.trim());
        final proteinTarget = double.tryParse(_proteinTarget.text.trim());
        final carbsTarget = double.tryParse(_carbsTarget.text.trim());
        final fatTarget = double.tryParse(_fatTarget.text.trim());
        final existing = _existingDietPlan;
        if (existing != null && existing.id.isNotEmpty) {
          await svc.updateDietPlan(
            gymId,
            existing.id,
            title: existing.title,
            meals: meals,
            dailyCalorieTarget: calorieTarget,
            dailyProteinTargetG: proteinTarget,
            dailyCarbsTargetG: carbsTarget,
            dailyFatTargetG: fatTarget,
          );
        } else {
          await svc.createDietPlan(
            gymId,
            title: 'Plan for ${widget.client.fullName}',
            memberId: widget.client.userId,
            meals: meals,
            dailyCalorieTarget: calorieTarget,
            dailyProteinTargetG: proteinTarget,
            dailyCarbsTargetG: carbsTarget,
            dailyFatTargetG: fatTarget,
          );
        }
      }

      // The member-scoped plan/target providers this sheet just wrote to are
      // read elsewhere (client detail's nutrition tab) — invalidate so they
      // refetch instead of showing stale pre-save data.
      ref.invalidate(memberWorkoutPlansProvider((gymId: gymId, userId: widget.client.userId)));
      ref.invalidate(memberDietPlansProvider((gymId: gymId, userId: widget.client.userId)));

      if (mounted) Navigator.of(context).pop(true);
    } on ApiFailure catch (e) {
      showError(e);
    } on Object catch (e) {
      showError(e);
    }
  }

  bool get _hasExistingForSelected =>
      _isWorkoutSelected ? _existingWorkoutPlan != null : _existingDietPlan != null;

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
                _hasExistingForSelected ? 'Update Plan' : 'Create Plan',
                style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                widget.client.fullName,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_loadingExisting)
            const Expanded(child: LoadingView(message: 'Loading current plan…'))
          else if (_loadError != null)
            Expanded(
              child: ErrorRetryView(message: _loadError!, onRetry: () {
                setState(() => _loadingExisting = true);
                _loadExisting();
              }),
            )
          else ...[
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
              label: _saving
                  ? 'Saving plan…'
                  : (_hasExistingForSelected ? 'Save & Update Plan' : 'Create & Assign Plan'),
              isEnabled: !_saving,
              onTap: _save,
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildWorkoutFields() {
    return [
      Text(
        _exercises.isEmpty ? 'No exercises yet' : 'Current Exercises',
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
      ),
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
      Text('Daily Macro Targets', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _calorieTarget,
              keyboardType: TextInputType.number,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: _getInputDecoration('Calories (kcal)'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _proteinTarget,
              keyboardType: TextInputType.number,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: _getInputDecoration('Protein (g)'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _carbsTarget,
              keyboardType: TextInputType.number,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: _getInputDecoration('Carbs (g)'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _fatTarget,
              keyboardType: TextInputType.number,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: _getInputDecoration('Fat (g)'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Text(
        _meals.isEmpty ? 'No meals yet' : 'Current Meal Plan',
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
      ),
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
