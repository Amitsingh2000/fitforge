import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/linear_progress_bar.dart';
import 'exercise_detail_screen.dart';

/// Member workout tracker for the trainer-assigned session of the day.
///
/// Lists the assigned exercises. Tapping any exercise opens the full-featured
/// [ExerciseDetailScreen] where the user records sets, rests, and finishes
/// the exercise.
class ExercisePlanContent extends StatefulWidget {
  const ExercisePlanContent({super.key});

  @override
  State<ExercisePlanContent> createState() => _ExercisePlanContentState();
}

class _ExercisePlanContentState extends State<ExercisePlanContent>
    with SingleTickerProviderStateMixin {
  // ── Trainer-assigned exercises ──
  static const List<WorkoutExercise> _exercises = [
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
      tips: [
        'Hinge at your hips, not your lower back.',
        'Keep the bar close to your body at all times.',
        'Feel the stretch in your hamstrings at the bottom.',
        'Squeeze your glutes at the top to lock out.',
      ],
    ),
    WorkoutExercise(
      name: 'Walking Lunges',
      detail: 'Strength • Glutes',
      sets: 3,
      reps: 12,
      restSeconds: 60,
      icon: Icons.directions_walk_rounded,
      color: AppColors.accentOrange,
      muscleGroup: 'Glutes',
      difficulty: 'Beginner',
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
      tips: [
        'Rise up onto the balls of your feet as high as possible.',
        'Hold at the top for a 1-second squeeze.',
        'Lower slowly for a full stretch.',
      ],
    ),
  ];

  // ── Per-exercise completion tracking ──
  late final List<bool> _exerciseCompleted;
  late final AnimationController _headerPulse;

  int get _completedCount =>
      _exerciseCompleted.where((done) => done).length;
  double get _overallProgress =>
      _exercises.isEmpty ? 0 : _completedCount / _exercises.length;
  bool get _allDone => _completedCount == _exercises.length;

  @override
  void initState() {
    super.initState();
    _exerciseCompleted =
        List.generate(_exercises.length, (_) => false);
    _headerPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerPulse.dispose();
    super.dispose();
  }

  String get _formattedDate {
    final now = DateTime.now();
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  int get _totalSets => _exercises.fold(0, (s, e) => s + e.sets);
  int get _estMinutes {
    // Rough estimate: 40s per set + rest between sets
    int seconds = 0;
    for (final ex in _exercises) {
      seconds += ex.sets * 40; // working time
      seconds += (ex.sets - 1) * ex.restSeconds; // rest between sets
    }
    return (seconds / 60).round();
  }

  void _openExercise(int index) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ExerciseDetailScreen(exercise: _exercises[index]),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      ),
    );
    if (mounted) {
      setState(() => _exerciseCompleted[index] = true);
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
              _buildProgressCard()
                  .animate()
                  .fadeIn(duration: 450.ms)
                  .slideY(begin: 0.05, end: 0),
              const SizedBox(height: 16),
              _buildSessionOverview()
                  .animate()
                  .fadeIn(duration: 450.ms, delay: 60.ms)
                  .slideY(begin: 0.05, end: 0),
              const SizedBox(height: 20),
              _sectionLabel('TODAY\'S ASSIGNMENT'),
              const SizedBox(height: 10),
              ...List.generate(
                _exercises.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildExerciseCard(index)
                      .animate(delay: (index * 65 + 100).ms)
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.05, end: 0),
                ),
              ),
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
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
                  'Today\'s Workout',
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
              color: AppColors.accentCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.accentCyan.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              'Trainer plan',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.accentCyan,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PROGRESS CARD ───

  Widget _buildProgressCard() {
    final title = _allDone
        ? 'Session complete'
        : '$_completedCount of ${_exercises.length} exercises done';
    final subtitle = _allDone
        ? 'Great job — every exercise is logged!'
        : 'Assigned by Alex Morgan • ~$_estMinutes min';
    return DashboardGlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.accentPurple.withValues(alpha: 0.14),
          AppColors.accentBlue.withValues(alpha: 0.05),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _allDone ? 'Session complete 🎉' : 'Lower body strength',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                '${(_overallProgress * 100).round()}%',
                style: AppTextStyles.titleLarge
                    .copyWith(color: AppColors.accentCyan),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressBar(
            progress: _overallProgress,
            color: _allDone ? const Color(0xFF22C55E) : AppColors.accentCyan,
            height: 5,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  // ─── SESSION OVERVIEW (Quick stats row) ───

  Widget _buildSessionOverview() {
    return Row(
      children: [
        _overviewStat(
          Icons.format_list_numbered_rounded,
          '${_exercises.length}',
          'Exercises',
          AppColors.accentBlue,
        ),
        const SizedBox(width: 10),
        _overviewStat(
          Icons.repeat_rounded,
          '$_totalSets',
          'Total Sets',
          AppColors.accentPurple,
        ),
        const SizedBox(width: 10),
        _overviewStat(
          Icons.timer_outlined,
          '~$_estMinutes min',
          'Duration',
          AppColors.accentOrange,
        ),
      ],
    );
  }

  Widget _overviewStat(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: DashboardGlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  // ─── EXERCISE CARD ───

  Widget _buildExerciseCard(int index) {
    final exercise = _exercises[index];
    final isDone = _exerciseCompleted[index];

    return DashboardGlassCard(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      borderColor: isDone
          ? const Color(0xFF22C55E).withValues(alpha: 0.3)
          : null,
      onTap: () => _openExercise(index),
      child: Column(
        children: [
          // ── Top gradient accent bar ──
          Container(
            height: 3,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [
                  exercise.color.withValues(alpha: 0.6),
                  exercise.color.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: exercise.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(exercise.icon,
                          color: exercise.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    // Title and detail
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
                          Text(exercise.detail,
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    // Status
                    if (isDone)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
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
                      Icon(Icons.chevron_right_rounded,
                          color: AppColors.textTertiary, size: 22),
                  ],
                ),
                const SizedBox(height: 14),
                // Quick stats row
                Row(
                  children: [
                    _exerciseQuickStat(
                        '${exercise.sets} sets', Icons.repeat_rounded),
                    _exerciseQuickStat(
                        '${exercise.reps} reps', Icons.tag_rounded),
                    _exerciseQuickStat('${exercise.restSeconds}s rest',
                        Icons.timer_outlined),
                    _exerciseQuickStat(
                        exercise.difficulty,
                        Icons.signal_cellular_alt_rounded),
                  ],
                ),
                const SizedBox(height: 12),
                // Tap to start prompt
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFF22C55E).withValues(alpha: 0.06)
                        : exercise.color.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDone
                          ? const Color(0xFF22C55E)
                              .withValues(alpha: 0.15)
                          : exercise.color.withValues(alpha: 0.15),
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
                        isDone ? 'Tap to view again' : 'Tap to start exercise',
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

  // ─── ALL DONE BANNER ───

  Widget _buildAllDoneBanner() {
    return DashboardGlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      borderColor: const Color(0xFF22C55E).withValues(alpha: 0.3),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF22C55E).withValues(alpha: 0.1),
          AppColors.bgSecondary,
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(Icons.emoji_events_rounded,
                color: Color(0xFF22C55E), size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            'All exercises complete!',
            style: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'You\'ve finished every exercise assigned for today. Your trainer will see your log.',
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
