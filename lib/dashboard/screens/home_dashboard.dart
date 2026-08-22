import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/daily_task.dart';
import '../../models/dashboard_today.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_flow_providers.dart';
import '../../services/member_dashboard_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../widgets/adaptive_nav_shell.dart';
import '../widgets/member_async_value.dart';
import '../widgets/state_views.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/radial_progress.dart';
import '../widgets/linear_progress_bar.dart';
import '../widgets/streak_flame.dart';
import 'diet_plan_screen.dart';
import 'exercise_plan_screen.dart';
import 'progress_analytics_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'billing_plans_screen.dart';
import 'rewards_screen.dart';
import '../../notifications/notifications_screen.dart';

class HomeDashboard extends ConsumerStatefulWidget {
  const HomeDashboard({super.key});

  @override
  ConsumerState<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends ConsumerState<HomeDashboard>
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
  
  bool _actionBusy = false;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _addWater(double amount) async {
    if (_actionBusy) return;
    setState(() => _actionBusy = true);
    try {
      await ref.read(memberDashboardServiceProvider).logWater(amountLiters: amount);
      invalidateDailyLoop(ref);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyApiError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _toggleTask(DailyTask task) async {
    if (task.completed || _actionBusy) return;
    setState(() => _actionBusy = true);
    try {
      await ref.read(memberDashboardServiceProvider).toggleTask(
            task.id,
            completed: true,
          );
      invalidateDailyLoop(ref);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyApiError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
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

          AdaptiveNavShell(
            selectedIndex: _currentNavIndex >= 4 ? 4 : _currentNavIndex,
            onSelect: (i) => setState(() => _currentNavIndex = i),
            items: const [
              AdaptiveNavItem(icon: Icons.home_rounded, label: 'Home'),
              AdaptiveNavItem(icon: Icons.restaurant_menu_rounded, label: 'Diet'),
              AdaptiveNavItem(icon: Icons.fitness_center_rounded, label: 'Workout'),
              AdaptiveNavItem(icon: Icons.insights_rounded, label: 'Progress'),
              AdaptiveNavItem(icon: Icons.person_rounded, label: 'Profile'),
            ],
            body: SafeArea(
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
        return const ExercisePlanContent(key: ValueKey('exercise'));
      case 3:
        return const ProgressAnalyticsContent(key: ValueKey('progress'));
      case 4:
        return ProfileContent(
          key: const ValueKey('profile'),
          onViewAchievements: () {
            setState(() {
              _currentNavIndex = 7;
            });
          },
          onManageBilling: () {
            setState(() {
              _currentNavIndex = 6;
            });
          },
        );
      case 5:
        return LeaderboardContent(
          key: const ValueKey('leaderboard'),
          onBack: () {
            setState(() {
              _currentNavIndex = 4;
            });
          },
        );
      case 6:
        return const BillingPlansContent(key: ValueKey('billing'));
      case 7:
        return StreakRewardsContent(
          key: const ValueKey('rewards'),
          onNavigateToLeaderboard: () {
            setState(() {
              _currentNavIndex = 5;
            });
          },
        );
      case 0:
      default:
        return _buildHomeContent(key: const ValueKey('home'));
    }
  }

  Widget _buildHomeContent({Key? key}) {
    final todayAsync = ref.watch(todayDashboardProvider);
    return MemberAsyncValue<DashboardToday>(
      value: todayAsync,
      loadingMessage: 'Loading today…',
      onRetry: () => ref.invalidate(todayDashboardProvider),
      builder: (today) => CustomScrollView(
        key: key,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildGreetingHeader(today)),
          SliverPadding(
            padding: Layout.scroll(context, horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSwipeableHeroSection(today)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 100.ms)
                    .slideY(
                        begin: 0.08, end: 0, duration: 600.ms, delay: 100.ms),
                const SizedBox(height: 14),
                _buildTasksSection(today.tasks)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 350.ms)
                    .slideY(
                        begin: 0.08, end: 0, duration: 500.ms, delay: 350.ms),
                const SizedBox(height: 14),
                _buildAIRecommendations(today)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 480.ms)
                    .slideY(
                        begin: 0.08, end: 0, duration: 500.ms, delay: 480.ms),
              ]),
            ),
          ),
        ],
      ),
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

  Widget _buildGreetingHeader(DashboardToday today) {
    final user = ref.watch(authProvider).user;
    final name = user?.firstName.isNotEmpty == true
        ? user!.firstName
        : (user?.name ?? 'Member');
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
                  '$_greeting, $name 👋',
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
          if (today.unreadNotifications > 0)
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
              icon: Badge(
                label: Text('${today.unreadNotifications}'),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ),
            ),
          // Right side: Streak badge (redirects to Streak & Rewards screen)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _currentNavIndex = 7; // Navigate to Rewards screen
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
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
                      '${today.streakDays} days',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
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
  // SWIPEABLE HERO SECTION  (Calories / Water / Steps)
  // ─────────────────────────────────────────────

  Widget _buildSwipeableHeroSection(DashboardToday today) {
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
                _buildCaloriesContent(today),
                _buildWaterContent(today),
                _buildStepsContent(today),
              ],
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── PAGE 1 CONTENT : Daily Calories ──
  Widget _buildCaloriesContent(DashboardToday today) {
    final consumed = today.calories.consumed;
    final target = today.calories.target <= 0 ? 2500 : today.calories.target;
    final progress = target > 0 ? consumed / target : 0.0;
    final remaining = target - consumed;

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
                          begin: 0, end: consumed.toDouble()),
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
                      '/ $target cal',
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
                value: '$consumed',
                unit: 'cal',
                color: AppColors.accentBlue,
              ),
              _buildStatDivider(),
              _buildMiniStat(
                emoji: '🎯',
                label: 'Target',
                value: '$target',
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
              'Progress', consumed, target, AppColors.accentBlue),
        ],
      ),
    );
  }

  // ── PAGE 2 CONTENT : Water Intake ──
  Widget _buildWaterContent(DashboardToday today) {
    final waterCurrent = today.water.currentLiters;
    final waterTarget = today.water.targetLiters;
    final progress = waterTarget > 0 ? waterCurrent / waterTarget : 0.0;

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
                      '${waterCurrent.toStringAsFixed(1)}L',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        height: 1,
                      ),
                    ),
                    Text(
                      '/ ${waterTarget.toStringAsFixed(0)}L goal',
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
                value: waterCurrent.toStringAsFixed(1),
                unit: 'L',
                color: AppColors.accentCyan,
              ),
              _buildStatDivider(),
              _buildMiniStat(
                emoji: '🎯',
                label: 'Target',
                value: waterTarget.toStringAsFixed(0),
                unit: 'L',
                color: AppColors.accentBlue,
              ),
              _buildStatDivider(),
              _buildMiniStat(
                emoji: '✨',
                label: 'Left',
                value: (waterTarget - waterCurrent).toStringAsFixed(1),
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
  Widget _buildStepsContent(DashboardToday today) {
    final stepsCurrent = today.steps.current;
    final stepsTarget = today.steps.target;
    final progress = stepsTarget > 0 ? stepsCurrent / stepsTarget : 0.0;
    final remaining = stepsTarget - stepsCurrent;
    final distanceKm = (stepsCurrent * 0.000762).toStringAsFixed(1);
    final caloriesBurned = (stepsCurrent * 0.04).round();

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
                          begin: 0, end: stepsCurrent.toDouble()),
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
                      '/ $stepsTarget steps',
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
              'Progress', stepsCurrent, stepsTarget, AppColors.accentPurple),
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

  Widget _buildTasksSection(List<DailyTask> tasks) {
    final completedCount = tasks.where((t) => t.completed).length;

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
                      '$completedCount / ${tasks.length} completed',
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
          ...List.generate(tasks.length, (index) {
            final task = tasks[index];
            final isCompleted = task.completed;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < tasks.length - 1 ? 10 : 0,
              ),
              child: GestureDetector(
                onTap: () => _toggleTask(task),
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
                          task.title,
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
                            '+${task.xp} XP',
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
  // AI RECOMMENDATIONS
  // ─────────────────────────────────────────────

  Widget _buildAIRecommendations(DashboardToday today) {
    final waterLeft = (today.water.targetLiters - today.water.currentLiters)
        .clamp(0, today.water.targetLiters);
    final insights = [
      {
        'title': 'Healthy Pace',
        'subtitle': 'Weight Management',
        'desc': 'Losing 0.5 kg/week — perfect pace that preserves lean muscle mass. Your body composition is improving.',
        'emoji': '💚',
        'color': AppColors.accentCyan,
        'tag': 'TRENDING',
        'confidence': 96,
      },
      {
        'title': 'Protein Peak',
        'subtitle': 'Nutrition Insight',
        'desc': '18% consistency improvement this month. Sustaining this level will accelerate body recomposition.',
        'emoji': '💪',
        'color': AppColors.accentBlue,
        'tag': 'NEW HIGH',
        'confidence': 91,
      },
      {
        'title': 'Hydration Goal',
        'subtitle': 'Habit Analysis',
        'desc': 'Daily water intake is up 25% vs last month. Optimal hydration is accelerating your metabolism.',
        'emoji': '💧',
        'color': AppColors.accentPurple,
        'tag': 'STREAK',
        'confidence': 88,
      },
    ];

    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header — same style as Tasks section ──
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
                      AppColors.accentBlue.withValues(alpha: 0.22),
                      AppColors.accentPurple.withValues(alpha: 0.22),
                    ],
                  ),
                ),
                child: const Center(
                  child: Text('🧠', style: TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Coach',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Personalized insights from your data',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Pulsing LIVE badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF22C55E),
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .scaleXY(begin: 0.5, end: 1.4, duration: 850.ms, curve: Curves.easeInOut)
                        .then()
                        .scaleXY(begin: 1.4, end: 0.5, duration: 850.ms),
                    const SizedBox(width: 5),
                    Text(
                      'LIVE',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF22C55E),
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Insight rows ──
          ...List.generate(insights.length, (index) {
            final insight = insights[index];
            final color = insight['color'] as Color;
            final confidence = insight['confidence'] as int;
            final tag = insight['tag'] as String;

            return Padding(
              padding: EdgeInsets.only(bottom: index < insights.length - 1 ? 12 : 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.14)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Emoji icon chip
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color.withValues(alpha: 0.22)),
                          ),
                          child: Center(
                            child: Text(
                              insight['emoji'] as String,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 11),
                        // Title + desc column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      insight['title'] as String,
                                      style: AppTextStyles.labelLarge.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Tag badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: color.withValues(alpha: 0.25)),
                                    ),
                                    child: Text(
                                      tag,
                                      style: AppTextStyles.caption.copyWith(
                                        color: color,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 8,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                insight['desc'] as String,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    // Category label + confidence %
                    Row(
                      children: [
                        Text(
                          insight['subtitle'] as String,
                          style: AppTextStyles.caption.copyWith(
                            color: color,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$confidence% confidence',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Confidence progress bar
                    Stack(
                      children: [
                        Container(
                          height: 4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.bgTertiary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: confidence / 100,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color.withValues(alpha: 0.6), color],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate(delay: (index * 70).ms)
                  .fadeIn(duration: 380.ms)
                  .slideY(begin: 0.06, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
            );
          }),

          const SizedBox(height: 14),

          // ── Today's Focus banner ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TODAY'S FOCUS",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        waterLeft > 0
                            ? 'Hit protein target + drink ${waterLeft.toStringAsFixed(1)}L more water to unlock your best recovery score.'
                            : 'Great hydration today — keep your protein on track for recovery.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
