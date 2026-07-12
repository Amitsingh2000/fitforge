import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/radial_progress.dart';
import '../widgets/linear_progress_bar.dart';
import '../widgets/streak_flame.dart';
import 'diet_plan_screen.dart';
import 'progress_analytics_screen.dart';
import 'rewards_screen.dart';
import 'profile_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  int _currentNavIndex = 0;

  // ── Hero swipe page controller ──
  late final PageController _heroPageController;
  int _heroCurrentPage = 1;

  int get _safeHeroCurrentPage {
    final dynamic page = _heroCurrentPage;
    if (page is int) {
      if (page >= 0 && page < 3) {
        return page;
      }
    }
    return 1;
  }
  
  // Simulated user data
  final int _caloriesConsumed = 2200;
  final int _caloriesTarget = 2500;
  double _waterCurrent = 2.5;
  final double _waterTarget = 4.0;
  final int _stepsCurrent = 6420;
  final int _stepsTarget = 10000;
  final int _currentStreak = 12;

  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Drink 4L Water', 'completed': false, 'xp': 50},
    {'title': 'Reach Protein Goal', 'completed': false, 'xp': 50},
    {'title': 'Walk 8000 Steps', 'completed': true, 'xp': 50},
    {'title': 'Complete Workout', 'completed': false, 'xp': 50},
  ];

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _addWater(double amount) {
    setState(() {
      _waterCurrent = (_waterCurrent + amount).clamp(0.0, _waterTarget);
    });
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index]['completed'] = !_tasks[index]['completed'];
    });
  }

  @override
  void initState() {
    super.initState();
    _heroPageController = PageController(initialPage: 1, viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _heroPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Ambient background glow (shared across all tabs)
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentBlue.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentPurple.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Tab content — switches based on bottom nav index
          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _buildCurrentPage(),
            ),
          ),

          // Bottom navigation (always visible)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigation()
                .animate()
                .fadeIn(duration: 600.ms, delay: 300.ms)
                .slideY(begin: 0.5, end: 0, duration: 600.ms, delay: 300.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentNavIndex) {
      case 1:
        return const DietPlanContent(key: ValueKey('diet'));
      case 2:
        return const ProgressAnalyticsContent(key: ValueKey('progress'));
      case 3:
        return const StreakRewardsContent(key: ValueKey('rewards'));
      case 4:
        return ProfileContent(
          key: const ValueKey('profile'),
          onViewAchievements: () {
            setState(() {
              _currentNavIndex = 3;
            });
          },
        );
      case 0:
      default:
        return _buildHomeContent(key: const ValueKey('home'));
    }
  }

  Widget _buildHomeContent({Key? key}) {
    return CustomScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Prominent greeting
        SliverToBoxAdapter(child: _buildGreetingHeader()),

        // Content
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Swipeable Hero Section ──
              _buildSwipeableHeroSection()
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 100.ms)
                  .slideY(
                      begin: 0.08, end: 0, duration: 600.ms, delay: 100.ms),
              const SizedBox(height: 14),

              // Daily Tasks
              _buildTasksSection()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 350.ms)
                  .slideY(
                      begin: 0.08, end: 0, duration: 500.ms, delay: 350.ms),
            ]),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // GREETING HEADER
  // ─────────────────────────────────────────────

  String get _formattedDate {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  Widget _buildGreetingHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Greeting and Date/Streak summary
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_greeting, Amit 👋',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  _formattedDate,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right side: Streak badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentOrange.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const StreakFlame(size: 13),
                const SizedBox(width: 4),
                Text(
                  '$_currentStreak days',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.1, end: 0, duration: 500.ms);
  }


  // ─────────────────────────────────────────────
  // SWIPEABLE HERO SECTION  (Calories / Water / Steps)
  // ─────────────────────────────────────────────

  Widget _buildSwipeableHeroSection() {
    const pageCount = 3;
    final labels = ['Calories', 'Water', 'Steps'];
    final icons = [
      Icons.local_fire_department_rounded,
      Icons.water_drop_rounded,
      Icons.directions_walk_rounded,
    ];
    final colors = [
      AppColors.accentBlue,
      AppColors.accentCyan,
      AppColors.accentPurple,
    ];

    // Animated gradient color that transitions with the page
    final activeColor = colors[_safeHeroCurrentPage];

    return DashboardGlassCard(
      padding: EdgeInsets.zero,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          activeColor.withValues(alpha: 0.07),
          AppColors.accentPurple.withValues(alpha: 0.03),
        ],
      ),
      child: Column(
        children: [
          // ── Segmented tab bar inside the card ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: List.generate(pageCount, (i) {
                  final isActive = i == _safeHeroCurrentPage;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _heroPageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? colors[i].withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                          border: isActive
                              ? Border.all(
                                  color: colors[i].withValues(alpha: 0.3),
                                )
                              : null,
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: colors[i].withValues(alpha: 0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icons[i],
                              size: 14,
                              color: isActive
                                  ? colors[i]
                                  : AppColors.textTertiary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              labels[i],
                              style: AppTextStyles.caption.copyWith(
                                color: isActive
                                    ? colors[i]
                                    : AppColors.textTertiary,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // ── Swipeable inner content ──
          SizedBox(
            height: 295,
            child: PageView(
              controller: _heroPageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _heroCurrentPage = index);
              },
              children: [
                _buildCaloriesContent(),
                _buildWaterContent(),
                _buildStepsContent(),
              ],
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── PAGE 1 CONTENT : Daily Calories ──
  Widget _buildCaloriesContent() {
    final progress = _caloriesConsumed / _caloriesTarget;
    final remaining = _caloriesTarget - _caloriesConsumed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Radial ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, _) {
              return RadialProgress(
                progress: animatedProgress,
                size: 120,
                strokeWidth: 10,
                progressColor: AppColors.accentBlue,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween(
                          begin: 0, end: _caloriesConsumed.toDouble()),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Text(
                          '${value.toInt()}',
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            height: 1,
                          ),
                        );
                      },
                    ),
                    Text(
                      '/ $_caloriesTarget cal',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Stat chips row
          Row(
            children: [
              _buildMiniStat(
                emoji: '🔥',
                label: 'Consumed',
                value: '$_caloriesConsumed',
                unit: 'cal',
                color: AppColors.accentBlue,
              ),
              _buildStatDivider(),
              _buildMiniStat(
                emoji: '🎯',
                label: 'Target',
                value: '$_caloriesTarget',
                unit: 'cal',
                color: AppColors.accentPurple,
              ),
              _buildStatDivider(),
              _buildMiniStat(
                emoji: '✨',
                label: 'Left',
                value: '$remaining',
                unit: 'cal',
                color: AppColors.accentCyan,
              ),
            ],
          ),

          // Progress bar
          _buildProgressRow(
              'Progress', _caloriesConsumed, _caloriesTarget, AppColors.accentBlue),
        ],
      ),
    );
  }

  // ── PAGE 2 CONTENT : Water Intake ──
  Widget _buildWaterContent() {
    final progress = _waterCurrent / _waterTarget;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Radial ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, _) {
              return RadialProgress(
                progress: animatedProgress,
                size: 120,
                strokeWidth: 10,
                progressColor: AppColors.accentCyan,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('💧', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(
                      '${_waterCurrent.toStringAsFixed(1)}L',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        height: 1,
                      ),
                    ),
                    Text(
                      '/ ${_waterTarget.toStringAsFixed(0)}L goal',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Quick-add buttons
          Row(
            children: [
              _buildWaterButton('+250ml', 0.25),
              const SizedBox(width: 8),
              _buildWaterButton('+500ml', 0.5),
              const SizedBox(width: 8),
              _buildWaterButton('+1L', 1.0),
            ],
          ),

          // Stat chips row
          Row(
            children: [
              _buildMiniStat(
                emoji: '💧',
                label: 'Consumed',
                value: _waterCurrent.toStringAsFixed(1),
                unit: 'L',
                color: AppColors.accentCyan,
              ),
              _buildStatDivider(),
              _buildMiniStat(
                emoji: '🎯',
                label: 'Target',
                value: _waterTarget.toStringAsFixed(0),
                unit: 'L',
                color: AppColors.accentBlue,
              ),
              _buildStatDivider(),
              _buildMiniStat(
                emoji: '✨',
                label: 'Left',
                value: (_waterTarget - _waterCurrent).toStringAsFixed(1),
                unit: 'L',
                color: AppColors.accentPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── PAGE 3 CONTENT : Step Count ──
  Widget _buildStepsContent() {
    final progress = _stepsCurrent / _stepsTarget;
    final remaining = _stepsTarget - _stepsCurrent;
    final distanceKm = (_stepsCurrent * 0.000762).toStringAsFixed(1);
    final caloriesBurned = (_stepsCurrent * 0.04).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Radial ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, _) {
              return RadialProgress(
                progress: animatedProgress,
                size: 120,
                strokeWidth: 10,
                progressColor: AppColors.accentPurple,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('👟', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween(
                          begin: 0, end: _stepsCurrent.toDouble()),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Text(
                          '${value.toInt()}',
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            height: 1,
                          ),
                        );
                      },
                    ),
                    Text(
                      '/ $_stepsTarget steps',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Stat chips row
          Row(
            children: [
              _buildMiniStat(
                emoji: '📍',
                label: 'Distance',
                value: distanceKm,
                unit: 'km',
                color: AppColors.accentPurple,
              ),
              _buildStatDivider(),
              _buildMiniStat(
                emoji: '🔥',
                label: 'Burned',
                value: '$caloriesBurned',
                unit: 'cal',
                color: AppColors.accentCoral,
              ),
              _buildStatDivider(),
              _buildMiniStat(
                emoji: '🏁',
                label: 'Left',
                value: '$remaining',
                unit: '',
                color: AppColors.accentOrange,
              ),
            ],
          ),

          // Progress bar
          _buildProgressRow(
              'Progress', _stepsCurrent, _stepsTarget, AppColors.accentPurple),
        ],
      ),
    );
  }

  // ── Shared mini stat (diet-tab style) ──
  Widget _buildMiniStat({
    required String emoji,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          Text(
            '$value$unit',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 38,
      color: AppColors.glassBorder,
    );
  }

  // ── Progress bar row ──
  Widget _buildProgressRow(String label, int current, int target, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: LinearProgressBar(
            progress: current / target,
            color: color,
            height: 5,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${(current / target * 100).round()}%',
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }


  // ── Water quick-add button ──
  Widget _buildWaterButton(String label, double amount) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _addWater(amount),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accentCyan.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.accentCyan.withValues(alpha: 0.2),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.accentCyan,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TODAY'S TASKS
  // ─────────────────────────────────────────────

  Widget _buildTasksSection() {
    final completedCount = _tasks.where((t) => t['completed']).length;

    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentBlue.withValues(alpha: 0.2),
                      AppColors.accentPurple.withValues(alpha: 0.2),
                    ],
                  ),
                ),
                child: const Center(
                  child: Text('✦', style: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Challenges',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$completedCount / ${_tasks.length} completed',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+50 XP each',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_tasks.length, (index) {
            final task = _tasks[index];
            final isCompleted = task['completed'] as bool;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _tasks.length - 1 ? 10 : 0,
              ),
              child: GestureDetector(
                onTap: () => _toggleTask(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.accentBlue.withValues(alpha: 0.06)
                        : AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.accentBlue.withValues(alpha: 0.2)
                          : AppColors.glassBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: isCompleted
                              ? AppColors.accentBlue
                              : Colors.transparent,
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.accentBlue
                                : AppColors.textDisabled,
                            width: 2,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task['title'],
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isCompleted
                                ? AppColors.textTertiary
                                : AppColors.textPrimary,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.accentBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+${task['xp']} XP',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accentBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }


  // ─────────────────────────────────────────────
  // BOTTOM NAVIGATION
  // ─────────────────────────────────────────────

  Widget _buildBottomNavigation() {
    final navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.restaurant_menu_rounded, 'label': 'Diet'},
      {'icon': Icons.insights_rounded, 'label': 'Progress'},
      {'icon': Icons.emoji_events_rounded, 'label': 'Rewards'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isActive = index == _currentNavIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentNavIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.accentBlue.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: isActive
                                ? AppColors.accentBlue
                                : AppColors.textTertiary,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: AppTextStyles.caption.copyWith(
                              color: isActive
                                  ? AppColors.accentBlue
                                  : AppColors.textTertiary,
                              fontSize: 10,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            child: Text(item['label'] as String),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
