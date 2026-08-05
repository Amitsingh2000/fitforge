import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/linear_progress_bar.dart';
import 'exercise_detail_screen.dart';

/// Member workout tracker for trainer-assigned and custom workout routines.
///
/// Features routine selection, exercise search & category filtering,
/// live session progress tracking, set count indicators, and seamless navigation
/// into the full-featured [ExerciseDetailScreen].
class ExercisePlanContent extends StatefulWidget {
  const ExercisePlanContent({super.key});

  @override
  State<ExercisePlanContent> createState() => _ExercisePlanContentState();
}

class _ExercisePlanContentState extends State<ExercisePlanContent>
    with SingleTickerProviderStateMixin {
  // ── Workout Routines Repository ──
  static const Map<String, List<WorkoutExercise>> _routines = {
    'Lower Body Power': [
      WorkoutExercise(
        name: 'Barbell Back Squat',
        detail: 'Strength • Lower body',
        sets: 4,
        reps: 8,
        restSeconds: 90,
        icon: Icons.fitness_center_rounded,
        color: AppColors.accentPurple,
        muscleGroup: 'Quadriceps',
        difficulty: 'Intermediate',
        equipment: 'Barbell & Rack',
        defaultWeight: 75.0,
        tips: [
          'Keep your chest up and back straight throughout the movement.',
          'Push through your heels when standing up.',
          'Go to parallel or slightly below for full range of motion.',
          'Brace your core before each rep.',
        ],
      ),
      WorkoutExercise(
        name: 'Romanian Deadlift',
        detail: 'Strength • Hamstrings',
        sets: 3,
        reps: 10,
        restSeconds: 90,
        icon: Icons.keyboard_double_arrow_up_rounded,
        color: AppColors.accentCyan,
        muscleGroup: 'Hamstrings',
        difficulty: 'Intermediate',
        equipment: 'Barbell',
        defaultWeight: 60.0,
        tips: [
          'Hinge at your hips, not your lower back.',
          'Keep the bar close to your body at all times.',
          'Feel the stretch in your hamstrings at the bottom.',
          'Squeeze your glutes at the top to lock out.',
        ],
      ),
      WorkoutExercise(
        name: 'Walking Lunges',
        detail: 'Hypertrophy • Glutes',
        sets: 3,
        reps: 12,
        restSeconds: 60,
        icon: Icons.directions_walk_rounded,
        color: AppColors.accentOrange,
        muscleGroup: 'Glutes',
        difficulty: 'Beginner',
        equipment: 'Dumbbells',
        defaultWeight: 16.0,
        tips: [
          'Take long, controlled steps forward.',
          'Your back knee should almost touch the ground.',
          'Keep your torso upright, don\'t lean forward.',
        ],
      ),
      WorkoutExercise(
        name: 'Standing Calf Raise',
        detail: 'Accessory • Calves',
        sets: 3,
        reps: 15,
        restSeconds: 45,
        icon: Icons.arrow_upward_rounded,
        color: AppColors.accentCoral,
        muscleGroup: 'Calves',
        difficulty: 'Beginner',
        equipment: 'Machine / Bodyweight',
        defaultWeight: 40.0,
        tips: [
          'Rise up onto the balls of your feet as high as possible.',
          'Hold at the top for a 1-second squeeze.',
          'Lower slowly for a full stretch.',
        ],
      ),
    ],
    'Upper Body Hypertrophy': [
      WorkoutExercise(
        name: 'Incline Bench Press',
        detail: 'Strength • Upper Chest',
        sets: 4,
        reps: 8,
        restSeconds: 90,
        icon: Icons.fitness_center_rounded,
        color: AppColors.accentBlue,
        muscleGroup: 'Chest',
        difficulty: 'Intermediate',
        equipment: 'Incline Bench & Barbell',
        defaultWeight: 65.0,
        tips: [
          'Set bench angle to 30 degrees.',
          'Control the descent to upper chest.',
          'Drive straight up without arching back excessively.',
        ],
      ),
      WorkoutExercise(
        name: 'Lat Pulldown',
        detail: 'Hypertrophy • Lats',
        sets: 4,
        reps: 10,
        restSeconds: 75,
        icon: Icons.vertical_align_bottom_rounded,
        color: AppColors.accentCyan,
        muscleGroup: 'Back',
        difficulty: 'Beginner',
        equipment: 'Cable Machine',
        defaultWeight: 55.0,
        tips: [
          'Pull down to collarbone level.',
          'Squeeze shoulder blades together at the bottom.',
          'Avoid swinging your body backward.',
        ],
      ),
      WorkoutExercise(
        name: 'Dumbbell Shoulder Press',
        detail: 'Strength • Shoulders',
        sets: 3,
        reps: 10,
        restSeconds: 60,
        icon: Icons.upload_rounded,
        color: AppColors.accentOrange,
        muscleGroup: 'Shoulders',
        difficulty: 'Intermediate',
        equipment: 'Dumbbells',
        defaultWeight: 20.0,
        tips: [
          'Keep core tight and lower back flush against seat.',
          'Press overhead without locking elbows aggressively.',
        ],
      ),
      WorkoutExercise(
        name: 'Cable Bicep Curl & Tricep Pushdown',
        detail: 'Superset • Arms',
        sets: 3,
        reps: 12,
        restSeconds: 60,
        icon: Icons.loop_rounded,
        color: AppColors.accentPurple,
        muscleGroup: 'Arms',
        difficulty: 'Beginner',
        equipment: 'Cable Machine',
        defaultWeight: 25.0,
        tips: [
          'Keep elbows pinned to your torso.',
          'Focus on peak contraction on every rep.',
        ],
      ),
    ],
    'Full Body HIIT & Core': [
      WorkoutExercise(
        name: 'Kettlebell Swings',
        detail: 'Conditioning • Posterior Chain',
        sets: 4,
        reps: 20,
        restSeconds: 45,
        icon: Icons.bolt_rounded,
        color: AppColors.accentCoral,
        muscleGroup: 'Full Body',
        difficulty: 'Intermediate',
        equipment: 'Kettlebell',
        defaultWeight: 20.0,
        tips: [
          'Hinge at hips to generate power, don\'t squat.',
          'Squeeze glutes at top lockout.',
        ],
      ),
      WorkoutExercise(
        name: 'Hanging Leg Raise',
        detail: 'Core • Abdominals',
        sets: 3,
        reps: 15,
        restSeconds: 45,
        icon: Icons.accessibility_new_rounded,
        color: AppColors.accentPurple,
        muscleGroup: 'Abs & Core',
        difficulty: 'Intermediate',
        equipment: 'Pull-up Bar',
        defaultWeight: 0.0,
        tips: [
          'Avoid swinging momentum; use strict ab engagement.',
          'Raise legs until hips flex past 90 degrees.',
        ],
      ),
      WorkoutExercise(
        name: 'Dumbbell Renegade Rows',
        detail: 'Stability • Back & Core',
        sets: 3,
        reps: 10,
        restSeconds: 60,
        icon: Icons.shield_rounded,
        color: AppColors.accentBlue,
        muscleGroup: 'Core & Back',
        difficulty: 'Advanced',
        equipment: 'Dumbbells',
        defaultWeight: 14.0,
        tips: [
          'Widen your foot stance for balance.',
          'Keep hips parallel to ground throughout row.',
        ],
      ),
    ],
  };

  // ── State ──
  String _selectedRoutineKey = 'Lower Body Power';
  String _selectedCategoryFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Per-exercise completion state keying on (routineName, exerciseIndex)
  final Map<String, List<bool>> _completionMap = {};

  @override
  void initState() {
    super.initState();
    _initCompletionMap();
  }

  void _initCompletionMap() {
    for (final entry in _routines.entries) {
      _completionMap[entry.key] = List.generate(entry.value.length, (_) => false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WorkoutExercise> get _currentExercises =>
      _routines[_selectedRoutineKey] ?? [];

  List<bool> get _currentCompletion =>
      _completionMap[_selectedRoutineKey] ?? [];

  int get _completedCount =>
      _currentCompletion.where((done) => done).length;

  double get _overallProgress => _currentExercises.isEmpty
      ? 0
      : _completedCount / _currentExercises.length;

  bool get _allDone =>
      _currentExercises.isNotEmpty && _completedCount == _currentExercises.length;

  int get _totalSets =>
      _currentExercises.fold(0, (sum, ex) => sum + ex.sets);

  int get _estMinutes {
    int seconds = 0;
    for (final ex in _currentExercises) {
      seconds += ex.sets * 40;
      seconds += (ex.sets - 1) * ex.restSeconds;
    }
    return (seconds / 60).round();
  }

  int get _estVolumeKg {
    int total = 0;
    for (final ex in _currentExercises) {
      total += (ex.sets * ex.reps * ex.defaultWeight).round();
    }
    return total;
  }

  List<String> get _categories {
    final set = <String>{'All'};
    for (final ex in _currentExercises) {
      set.add(ex.muscleGroup);
    }
    return set.toList();
  }

  List<int> get _filteredIndices {
    final list = <int>[];
    for (int i = 0; i < _currentExercises.length; i++) {
      final ex = _currentExercises[i];
      final matchesCategory = _selectedCategoryFilter == 'All' ||
          ex.muscleGroup == _selectedCategoryFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          ex.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ex.muscleGroup.toLowerCase().contains(_searchQuery.toLowerCase());
      if (matchesCategory && matchesSearch) {
        list.add(i);
      }
    }
    return list;
  }

  String get _formattedDate {
    final now = DateTime.now();
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  void _openExercise(int index) async {
    final exercise = _currentExercises[index];
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ExerciseDetailScreen(exercise: exercise),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
      ),
    );
    if (mounted) {
      setState(() {
        _currentCompletion[index] = true;
      });
    }
  }

  // ──────────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Routine selector bar
              _buildRoutineSelectorBar()
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.04, end: 0),
              const SizedBox(height: 14),

              // Progress Hero Card (styled like Meal Plan progress)
              _buildProgressHeroCard()
                  .animate()
                  .fadeIn(duration: 450.ms, delay: 50.ms)
                  .slideY(begin: 0.04, end: 0),
              const SizedBox(height: 20),

              // Search & Muscle Group Filter pills
              _buildSearchAndFilters()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 140.ms),
              const SizedBox(height: 16),

              // Section Label
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionLabel('ASSIGNED EXERCISES (${_filteredIndices.length})'),
                  if (_completedCount > 0)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          for (int i = 0; i < _currentCompletion.length; i++) {
                            _currentCompletion[i] = false;
                          }
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.textTertiary,
                      ),
                      child: Text('Reset Progress',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textTertiary, fontSize: 11)),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Exercises List
              if (_filteredIndices.isEmpty)
                _buildEmptySearchState()
              else
                ..._filteredIndices.map((index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildExerciseCard(index)
                        .animate(delay: (index * 55 + 160).ms)
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.04, end: 0),
                  );
                }),

              // All Done Celebration Banner
              if (_allDone) ...[
                const SizedBox(height: 8),
                _buildAllDoneBanner()
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1)),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  // ─── HEADER ───

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.accentPurple.withValues(alpha: 0.12),
            ),
            child: const Icon(Icons.fitness_center_rounded,
                color: AppColors.accentPurple, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workout & Exercise',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(_formattedDate, style: AppTextStyles.caption),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.accentBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: AppColors.accentBlue, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Trainer Plan',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── ROUTINE SELECTOR BAR ───

  Widget _buildRoutineSelectorBar() {
    final routinesList = _routines.keys.toList();
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: routinesList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final name = routinesList[i];
          final isSelected = name == _selectedRoutineKey;
          return InkWell(
            onTap: () {
              setState(() {
                _selectedRoutineKey = name;
                _selectedCategoryFilter = 'All';
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentBlue
                    : AppColors.bgSecondary.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentBlue
                      : AppColors.glassBorder,
                ),
              ),
              child: Text(
                name,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── PROGRESS HERO CARD (MATCHING MEAL PLAN PROGRESS) ───

  Widget _buildProgressHeroCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Motivational text pill (matching Meal Plan header)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentPurple.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.accentPurple.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✦', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Text(
                'Stay consistent. Every set counts.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.accentPurple.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Glass Progress Card (Matching Meal Plan Progress layout)
        DashboardGlassCard(
          padding: const EdgeInsets.all(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accentBlue.withValues(alpha: 0.08),
              AppColors.accentPurple.withValues(alpha: 0.04),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upper Row: Title & Percentage Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workout Session Progress',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_completedCount of ${_currentExercises.length} exercises done',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(_overallProgress * 100).round()}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Progress Bar
              LinearProgressBar(
                progress: _overallProgress,
                color: AppColors.accentBlue,
                height: 4,
              ),

              // Divider Line
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Container(
                  height: 1,
                  color: AppColors.glassBorder,
                ),
              ),

              // Lower Row: Metrics Summary (Matching Meal Plan Macro Summary)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _progressMetric('Routine', _selectedRoutineKey, AppColors.accentBlue),
                  _progressMetric('Total Sets', '$_totalSets', AppColors.accentPurple),
                  _progressMetric('Est Volume', '$_estVolumeKg kg', AppColors.accentCyan),
                  _progressMetric('Duration', '~$_estMinutes min', AppColors.accentOrange),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _progressMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 9,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ─── SEARCH & FILTER PILLS ───

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.bgSecondary.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search exercise or muscle group...',
              hintStyle: AppTextStyles.caption,
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.textTertiary, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded,
                          color: AppColors.textTertiary, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (ctx, i) {
              final cat = _categories[i];
              final isSel = cat == _selectedCategoryFilter;
              return ChoiceChip(
                label: Text(cat),
                selected: isSel,
                onSelected: (val) {
                  if (val) setState(() => _selectedCategoryFilter = cat);
                },
                selectedColor: AppColors.accentPurple.withValues(alpha: 0.25),
                backgroundColor: AppColors.bgSecondary.withValues(alpha: 0.5),
                labelStyle: AppTextStyles.caption.copyWith(
                  color: isSel ? AppColors.accentPurple : AppColors.textSecondary,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSel ? AppColors.accentPurple : AppColors.glassBorder,
                  ),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── EXERCISE CARD ───

  Widget _buildExerciseCard(int index) {
    final exercise = _currentExercises[index];
    final isDone = _currentCompletion[index];

    return DashboardGlassCard(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      borderColor: isDone
          ? const Color(0xFF22C55E).withValues(alpha: 0.35)
          : null,
      onTap: () => _openExercise(index),
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [
                  exercise.color,
                  exercise.color.withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: exercise.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(exercise.icon,
                          color: exercise.color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(exercise.detail, style: AppTextStyles.caption),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _tagBadge(
                                  exercise.muscleGroup, exercise.color),
                              const SizedBox(width: 6),
                              _tagBadge(exercise.difficulty,
                                  AppColors.accentOrange),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isDone)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E)
                              .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF22C55E), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Done',
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFF22C55E),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textTertiary, size: 22),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _exerciseQuickStat(
                        '${exercise.sets} sets', Icons.repeat_rounded),
                    _exerciseQuickStat(
                        '${exercise.reps} reps', Icons.tag_rounded),
                    _exerciseQuickStat('${exercise.restSeconds}s rest',
                        Icons.timer_outlined),
                    _exerciseQuickStat(
                        exercise.equipment, Icons.fitness_center_rounded),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFF22C55E).withValues(alpha: 0.08)
                        : exercise.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDone
                          ? const Color(0xFF22C55E).withValues(alpha: 0.2)
                          : exercise.color.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isDone
                            ? Icons.replay_rounded
                            : Icons.play_arrow_rounded,
                        color: isDone
                            ? const Color(0xFF22C55E)
                            : exercise.color,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isDone
                            ? 'Completed • Tap to review sets'
                            : 'Tap to start exercise log',
                        style: AppTextStyles.caption.copyWith(
                          color: isDone
                              ? const Color(0xFF22C55E)
                              : exercise.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _exerciseQuickStat(String text, IconData icon) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 12),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(
                fontSize: 9,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return DashboardGlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded,
                color: AppColors.textTertiary, size: 32),
            const SizedBox(height: 8),
            Text(
              'No matching exercises found',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search query or filter tags',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  // ─── ALL DONE CELEBRATION BANNER ───

  Widget _buildAllDoneBanner() {
    return DashboardGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      borderColor: const Color(0xFF22C55E).withValues(alpha: 0.35),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF22C55E).withValues(alpha: 0.12),
          AppColors.bgSecondary,
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.16),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.emoji_events_rounded,
                color: Color(0xFF22C55E), size: 32),
          ),
          const SizedBox(height: 14),
          Text(
            'Session fully completed!',
            style: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'You completed all exercises for $_selectedRoutineKey! +150 XP earned.',
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: AppTextStyles.caption.copyWith(
          letterSpacing: 1.2,
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w700,
        ),
      );
}
