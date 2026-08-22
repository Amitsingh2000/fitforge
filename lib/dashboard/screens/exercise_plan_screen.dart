import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/workout_today.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_flow_providers.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../utils/workout_mapper.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/linear_progress_bar.dart';
import '../widgets/member_async_value.dart';
import '../widgets/state_views.dart';
import 'exercise_detail_screen.dart';

/// Member workout tracker for trainer-assigned and custom workout routines.
///
/// Features routine selection, exercise search & category filtering,
/// live session progress tracking, set count indicators, and seamless navigation
/// into the full-featured [ExerciseDetailScreen].
class ExercisePlanContent extends ConsumerStatefulWidget {
  const ExercisePlanContent({super.key});

  @override
  ConsumerState<ExercisePlanContent> createState() => _ExercisePlanContentState();
}

class _ExercisePlanContentState extends ConsumerState<ExercisePlanContent> {
  String _selectedCategoryFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Per-exercise completion state keyed by workout entry id.
  final Map<String, bool> _completionMap = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WorkoutExercise> _mappedExercises(WorkoutToday data) =>
      data.exercises.map(mapWorkoutEntry).toList();

  bool _isExerciseDone(WorkoutExerciseEntry entry) =>
      _completionMap[entry.id] ?? false;

  int _completedCount(WorkoutToday data) =>
      data.exercises.where((e) => _isExerciseDone(e)).length;

  double _overallProgress(WorkoutToday data) {
    final total = data.exercises.length;
    return total == 0 ? 0 : _completedCount(data) / total;
  }

  bool _allDone(WorkoutToday data) =>
      data.exercises.isNotEmpty && _completedCount(data) == data.exercises.length;

  int _totalSets(WorkoutToday data) =>
      data.exercises.fold(0, (sum, ex) => sum + (ex.sets ?? 0));

  int _estMinutes(WorkoutToday data) {
    int seconds = 0;
    for (final ex in data.exercises) {
      final sets = ex.sets ?? 3;
      seconds += sets * 40;
      seconds += (sets - 1) * (ex.restSeconds ?? 60);
    }
    return (seconds / 60).round();
  }

  int _estVolumeKg(WorkoutToday data) {
    int total = 0;
    for (final ex in data.exercises) {
      final mapped = mapWorkoutEntry(ex);
      total += (mapped.sets * mapped.reps * mapped.defaultWeight).round();
    }
    return total;
  }

  List<String> _categories(WorkoutToday data) {
    final set = <String>{'All'};
    for (final ex in _mappedExercises(data)) {
      set.add(ex.muscleGroup);
    }
    return set.toList();
  }

  List<int> _filteredIndices(WorkoutToday data) {
    final exercises = _mappedExercises(data);
    final list = <int>[];
    for (int i = 0; i < exercises.length; i++) {
      final ex = exercises[i];
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

  bool _hasActiveGymMembership() {
    final user = ref.read(authProvider).user;
    return user?.gymMemberships
            .any((m) => m.status.toUpperCase() == 'ACTIVE') ??
        false;
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

  void _openExercise(WorkoutToday data, int index) async {
    final entry = data.exercises[index];
    final exercise = mapWorkoutEntry(entry);
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
        _completionMap[entry.id] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutAsync = ref.watch(workoutTodayProvider);
    return MemberAsyncValue<WorkoutToday>(
      value: workoutAsync,
      loadingMessage: 'Loading today\'s workout…',
      onRetry: () => ref.invalidate(workoutTodayProvider),
      builder: (data) {
        if (data.workout == null) {
          return _buildNoWorkoutView();
        }
        return _buildWorkoutView(data);
      },
    );
  }

  Widget _buildNoWorkoutView() {
    final isGymMember = _hasActiveGymMembership();
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateView(
            icon: Icons.fitness_center_rounded,
            title: isGymMember
                ? 'No workout assigned today'
                : 'No workout scheduled',
            subtitle: isGymMember
                ? 'Your trainer hasn\'t assigned a session for today yet. Check back later or message your coach.'
                : 'You don\'t have a trainer plan yet. Browse workouts or ask a coach to get started.',
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutView(WorkoutToday data) {
    final filtered = _filteredIndices(data);
    final completedCount = _completedCount(data);
    final workoutTitle = data.workout!.title;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(workoutTitle: workoutTitle)),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, Layout.navClearance(context)),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildProgressHeroCard(data)
                  .animate()
                  .fadeIn(duration: 450.ms, delay: 50.ms)
                  .slideY(begin: 0.04, end: 0),
              const SizedBox(height: 20),
              _buildSearchAndFilters(data)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 140.ms),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionLabel('ASSIGNED EXERCISES (${filtered.length})'),
                  if (completedCount > 0)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          for (final entry in data.exercises) {
                            _completionMap.remove(entry.id);
                          }
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.textTertiary,
                      ),
                      child: Text(
                        'Reset Progress',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (filtered.isEmpty)
                _buildEmptySearchState()
              else
                ...filtered.map((index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildExerciseCard(data, index)
                        .animate(delay: (index * 55 + 160).ms)
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.04, end: 0),
                  );
                }),
              if (_allDone(data)) ...[
                const SizedBox(height: 8),
                _buildAllDoneBanner(workoutTitle)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                    ),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader({String? workoutTitle}) {
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
                  workoutTitle ?? 'Workout & Exercise',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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

  Widget _buildProgressHeroCard(WorkoutToday data) {
    final workoutTitle = data.workout!.title;
    final completedCount = _completedCount(data);
    final overallProgress = _overallProgress(data);
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
                        '$completedCount of ${data.exercises.length} exercises done',
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
                      '${(overallProgress * 100).round()}%',
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
                progress: overallProgress,
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
                  _progressMetric('Routine', workoutTitle, AppColors.accentBlue),
                  _progressMetric('Total Sets', '${_totalSets(data)}', AppColors.accentPurple),
                  _progressMetric('Est Volume', '${_estVolumeKg(data)} kg', AppColors.accentCyan),
                  _progressMetric('Duration', '~${_estMinutes(data)} min', AppColors.accentOrange),
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

  Widget _buildSearchAndFilters(WorkoutToday data) {
    final categories = _categories(data);
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
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (ctx, i) {
              final cat = categories[i];
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

  Widget _buildExerciseCard(WorkoutToday data, int index) {
    final entry = data.exercises[index];
    final exercise = mapWorkoutEntry(entry);
    final isDone = _isExerciseDone(entry);

    return DashboardGlassCard(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      borderColor: isDone
          ? const Color(0xFF22C55E).withValues(alpha: 0.35)
          : null,
      onTap: () => _openExercise(data, index),
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

  Widget _buildAllDoneBanner(String workoutTitle) {
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
            'You completed all exercises for $workoutTitle! +150 XP earned.',
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
