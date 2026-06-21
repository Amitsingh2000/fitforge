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

  // Simulated user data
  final int _caloriesConsumed = 2200;
  final int _caloriesTarget = 2500;
  final int _proteinCurrent = 92;
  final int _proteinTarget = 140;
  final int _carbsCurrent = 145;
  final int _carbsTarget = 220;
  final int _fatsCurrent = 42;
  final int _fatsTarget = 70;
  double _waterCurrent = 2.5;
  final double _waterTarget = 4.0;
  final int _currentStreak = 12;
  final int _longestStreak = 28;
  final int _xpToday = 450;

  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Drink 4L Water', 'completed': false, 'xp': 50},
    {'title': 'Reach Protein Goal', 'completed': false, 'xp': 50},
    {'title': 'Walk 8000 Steps', 'completed': true, 'xp': 50},
    {'title': 'Complete Workout', 'completed': false, 'xp': 50},
  ];

  final List<Map<String, dynamic>> _meals = [
    {
      'name': 'Breakfast',
      'time': '8:00 AM',
      'calories': 520,
      'protein': 28,
      'icon': '🥣',
    },
    {
      'name': 'Lunch',
      'time': '1:00 PM',
      'calories': 680,
      'protein': 35,
      'icon': '🥗',
    },
    {
      'name': 'Dinner',
      'time': '7:30 PM',
      'calories': 750,
      'protein': 42,
      'icon': '🍽️',
    },
    {
      'name': 'Snack',
      'time': '4:00 PM',
      'calories': 250,
      'protein': 12,
      'icon': '🥜',
    },
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
        // Top greeting bar
        SliverToBoxAdapter(child: _buildGreetingHeader()),

        // Content
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Calorie hero card
              _buildCalorieHeroCard()
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 100.ms)
                  .slideY(begin: 0.08, end: 0, duration: 600.ms, delay: 100.ms),
              const SizedBox(height: 16),

              // Macro tracking
              _buildSectionLabel('MACROS'),
              const SizedBox(height: 12),
              _buildMacroCards()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 250.ms)
                  .slideY(begin: 0.08, end: 0, duration: 500.ms, delay: 250.ms),
              const SizedBox(height: 20),

              // Hydration
              _buildSectionLabel('HYDRATION'),
              const SizedBox(height: 12),
              _buildHydrationCard()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 350.ms)
                  .slideY(begin: 0.08, end: 0, duration: 500.ms, delay: 350.ms),
              const SizedBox(height: 20),

              // Daily Tasks
              _buildSectionLabel('TODAY\'S TASKS'),
              const SizedBox(height: 12),
              _buildTasksSection()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 450.ms)
                  .slideY(begin: 0.08, end: 0, duration: 500.ms, delay: 450.ms),
              const SizedBox(height: 20),

              // Streak & XP
              _buildSectionLabel('STREAK & XP'),
              const SizedBox(height: 12),
              _buildStreakXPSection()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 550.ms)
                  .slideY(begin: 0.08, end: 0, duration: 500.ms, delay: 550.ms),
              const SizedBox(height: 20),

              // Today's Meals
              _buildSectionLabel('TODAY\'S MEALS'),
              const SizedBox(height: 12),
              _buildMealsSection()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 650.ms)
                  .slideY(begin: 0.08, end: 0, duration: 500.ms, delay: 650.ms),
              const SizedBox(height: 16),

              // View Full Diet Plan CTA
              _buildDietPlanCta()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 750.ms)
                  .slideY(begin: 0.08, end: 0, duration: 500.ms, delay: 750.ms),
            ]),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // GREETING HEADER
  // ─────────────────────────────────────────────

  Widget _buildGreetingHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accentBlue, AppColors.accentPurple],
              ),
            ),
            child: Center(
              child: Text(
                'A',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting, Amit',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const StreakFlame(size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$_currentStreak Day Streak',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                  Positioned(
                    top: 11,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.accentCoral,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentCoral.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
  // SECTION LABEL
  // ─────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.caption.copyWith(
        letterSpacing: 1.2,
        color: AppColors.textTertiary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CALORIE HERO CARD
  // ─────────────────────────────────────────────

  Widget _buildCalorieHeroCard() {
    final progress = _caloriesConsumed / _caloriesTarget;
    final remaining = _caloriesTarget - _caloriesConsumed;

    return DashboardGlassCard(
      padding: const EdgeInsets.all(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.accentBlue.withValues(alpha: 0.08),
          AppColors.accentPurple.withValues(alpha: 0.05),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Calories',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, _) {
              return RadialProgress(
                progress: animatedProgress,
                size: 180,
                strokeWidth: 14,
                progressColor: AppColors.accentBlue,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: _caloriesConsumed.toDouble()),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTextStyles.displayLarge.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '/ $_caloriesTarget cal',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildCalorieStat(
                  label: 'Consumed',
                  value: '$_caloriesConsumed',
                  color: AppColors.accentBlue,
                  icon: Icons.local_fire_department_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AppColors.glassBorder,
              ),
              Expanded(
                child: _buildCalorieStat(
                  label: 'Remaining',
                  value: '$remaining',
                  color: AppColors.accentCyan,
                  icon: Icons.flag_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieStat({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // MACRO TRACKING CARDS
  // ─────────────────────────────────────────────

  Widget _buildMacroCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMacroCard(
            emoji: '💪',
            label: 'Protein',
            current: _proteinCurrent,
            target: _proteinTarget,
            unit: 'g',
            color: AppColors.accentBlue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMacroCard(
            emoji: '🌾',
            label: 'Carbs',
            current: _carbsCurrent,
            target: _carbsTarget,
            unit: 'g',
            color: AppColors.accentPurple,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMacroCard(
            emoji: '🥑',
            label: 'Fats',
            current: _fatsCurrent,
            target: _fatsTarget,
            unit: 'g',
            color: AppColors.accentCoral,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroCard({
    required String emoji,
    required String label,
    required int current,
    required int target,
    required String unit,
    required Color color,
  }) {
    final progress = current / target;

    return DashboardGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const Spacer(),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$current',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                TextSpan(
                  text: ' / $target$unit',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressBar(
            progress: progress,
            color: color,
            height: 4,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HYDRATION CARD
  // ─────────────────────────────────────────────

  Widget _buildHydrationCard() {
    final progress = _waterCurrent / _waterTarget;

    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💧', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                'Water Intake',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentCyan,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${_waterCurrent.toStringAsFixed(1)}L',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ ${_waterTarget.toStringAsFixed(0)}L',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressBar(
            progress: progress,
            color: AppColors.accentCyan,
            height: 8,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildWaterButton('+250ml', 0.25),
              const SizedBox(width: 10),
              _buildWaterButton('+500ml', 0.5),
              const SizedBox(width: 10),
              _buildWaterButton('+1L', 1.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterButton(String label, double amount) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _addWater(amount),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
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
                  child: Text('✦', style: TextStyle(fontSize: 16)),
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
                        fontSize: 15,
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                bottom: index < _tasks.length - 1 ? 8 : 0,
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
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
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
                                size: 14,
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
                            color: AppColors.accentBlue.withValues(alpha: 0.1),
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
  // STREAK & XP SECTION
  // ─────────────────────────────────────────────

  Widget _buildStreakXPSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStreakCard(
            emoji: '🔥',
            label: 'CURRENT STREAK',
            value: '$_currentStreak Days',
            color: AppColors.accentOrange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStreakCard(
            emoji: '🏆',
            label: 'BEST STREAK',
            value: '$_longestStreak Days',
            color: AppColors.accentCoral,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStreakCard(
            emoji: '⚡',
            label: 'XP TODAY',
            value: '$_xpToday',
            color: AppColors.accentPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard({
    required String emoji,
    required String label,
    required String value,
    required Color color,
  }) {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 0.5,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TODAY'S MEALS PREVIEW
  // ─────────────────────────────────────────────

  Widget _buildMealsSection() {
    return Column(
      children: _meals.asMap().entries.map((entry) {
        final index = entry.key;
        final meal = entry.value;
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < _meals.length - 1 ? 10 : 0,
          ),
          child: _buildMealCard(meal),
        );
      }).toList(),
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                meal['icon'],
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal['name'],
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  meal['time'],
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal['calories']} cal',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.accentBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${meal['protein']}g protein',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // VIEW FULL DIET PLAN CTA
  // ─────────────────────────────────────────────

  Widget _buildDietPlanCta() {
    return GestureDetector(
      onTap: () => setState(() => _currentNavIndex = 1),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.accentBlue, Color(0xFF6366F1)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBlue.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View Full Diet Plan',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
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
