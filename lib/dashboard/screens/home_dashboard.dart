import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/brilliant_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/radial_progress.dart';
import '../widgets/linear_progress_bar.dart';
import '../widgets/streak_flame.dart';
import 'diet_plan_screen.dart';
import 'progress_analytics_screen.dart';
import 'rewards_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'billing_plans_screen.dart';

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
  final int _currentXP = 1450;

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
      backgroundColor: BrilliantColors.bgPrimary,
      body: Stack(
        children: [
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
                    BrilliantColors.mint.withValues(alpha: 0.08),
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
                    BrilliantColors.amber.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
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

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigation()
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.3, end: 0, duration: 400.ms),
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
        return StreakRewardsContent(
          key: const ValueKey('rewards'),
          onNavigateToLeaderboard: () {
            setState(() {
              _currentNavIndex = 5;
            });
          },
        );
      case 4:
        return ProfileContent(
          key: const ValueKey('profile'),
          onViewAchievements: () {
            setState(() {
              _currentNavIndex = 3;
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
              _currentNavIndex = 3;
            });
          },
        );
      case 6:
        return const BillingPlansContent(key: ValueKey('billing'));
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
        SliverToBoxAdapter(child: _buildGreetingHeader()),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSwipeableHeroSection()
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.05, end: 0, duration: 400.ms),
              const SizedBox(height: 16),

              _buildTasksSection()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.05, end: 0, duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 16),

              _buildAIRecommendations()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.05, end: 0, duration: 400.ms, delay: 200.ms),
            ]),
          ),
        ),
      ],
    );
  }

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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_greeting, Amit 👋',
                  style: BrilliantTheme.headerStyle(fontSize: 22),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 3),
                Text(
                  _formattedDate,
                  style: BrilliantTheme.bodyStyle(
                    fontSize: 12,
                    color: BrilliantColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _currentNavIndex = 3),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: BrilliantColors.bgSecondary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: BrilliantColors.surfaceBorder, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        '$_currentXP',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: BrilliantColors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _currentNavIndex = 3),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: BrilliantColors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: BrilliantColors.amber.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const StreakFlame(size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$_currentStreak',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: BrilliantColors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeableHeroSection() {
    const pageCount = 3;
    final labels = ['Calories', 'Water', 'Steps'];
    final icons = [
      Icons.local_fire_department_rounded,
      Icons.water_drop_rounded,
      Icons.directions_walk_rounded,
    ];
    final colors = [
      BrilliantColors.coral,
      BrilliantColors.mint,
      BrilliantColors.purple,
    ];

    return DashboardGlassCard(
      padding: EdgeInsets.zero,
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: BrilliantColors.bgPrimary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: BrilliantColors.surfaceBorder),
              ),
              child: Row(
                children: List.generate(pageCount, (i) {
                  final isActive = i == _safeHeroCurrentPage;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _heroPageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? colors[i].withValues(alpha: 0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isActive
                              ? Border.all(color: colors[i].withValues(alpha: 0.5), width: 1.5)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icons[i],
                              size: 15,
                              color: isActive ? colors[i] : BrilliantColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              labels[i],
                              style: TextStyle(
                                color: isActive ? colors[i] : BrilliantColors.textMuted,
                                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 12,
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

          SizedBox(
            height: 300,
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
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildCaloriesContent() {
    final progress = _caloriesConsumed / _caloriesTarget;
    final remaining = _caloriesTarget - _caloriesConsumed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RadialProgress(
            progress: progress,
            size: 130,
            strokeWidth: 12,
            progressColor: BrilliantColors.coral,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 2),
                Text(
                  '$_caloriesConsumed',
                  style: BrilliantTheme.headerStyle(fontSize: 24),
                ),
                Text(
                  '/ $_caloriesTarget cal',
                  style: BrilliantTheme.bodyStyle(
                    fontSize: 11,
                    color: BrilliantColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              _buildMiniStat(
                emoji: '🔥',
                label: 'Consumed',
                value: '$_caloriesConsumed',
                unit: 'cal',
                color: BrilliantColors.coral,
              ),
              _buildStatDivider(),
              _buildMiniStat(
                emoji: '🎯',
                label: 'Target',
                value: '$_caloriesTarget',
                unit: 'cal',
                color: BrilliantColors.amber,
              ),
              _buildStatDivider(),
              _buildMiniStat(
                emoji: '✨',
                label: 'Left',
                value: '$remaining',
                unit: 'cal',
                color: BrilliantColors.mint,
              ),
            ],
          ),

          _buildProgressRow(
              'Progress', _caloriesConsumed, _caloriesTarget, BrilliantColors.coral),
        ],
      ),
    );
  }

  Widget _buildWaterContent() {
    final progress = _waterCurrent / _waterTarget;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RadialProgress(
            progress: progress,
            size: 130,
            strokeWidth: 12,
            progressColor: BrilliantColors.mint,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💧', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 2),
                Text(
                  '${_waterCurrent.toStringAsFixed(1)}L',
                  style: BrilliantTheme.headerStyle(fontSize: 24),
                ),
                Text(
                  '/ ${_waterTarget.toStringAsFixed(1)}L target',
                  style: BrilliantTheme.bodyStyle(
                    fontSize: 11,
                    color: BrilliantColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BrilliantButton(
                onPressed: () => _addWater(0.25),
                color: BrilliantColors.bgTertiary,
                shadowColor: BrilliantColors.surfaceBorder,
                textColor: BrilliantColors.mint,
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: const Text('+250ml', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              BrilliantButton(
                onPressed: () => _addWater(0.50),
                color: BrilliantColors.bgTertiary,
                shadowColor: BrilliantColors.surfaceBorder,
                textColor: BrilliantColors.mint,
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: const Text('+500ml', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              BrilliantButton(
                onPressed: () => _addWater(1.0),
                color: BrilliantColors.mint,
                shadowColor: BrilliantColors.mintDark,
                textColor: BrilliantColors.textInverse,
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: const Text('+1.0L', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),

          _buildProgressRow(
              'Hydration Goal', (_waterCurrent * 100).toInt(), (_waterTarget * 100).toInt(), BrilliantColors.mint),
        ],
      ),
    );
  }

  Widget _buildStepsContent() {
    final progress = _stepsCurrent / _stepsTarget;
    final remaining = _stepsTarget - _stepsCurrent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RadialProgress(
            progress: progress,
            size: 130,
            strokeWidth: 12,
            progressColor: BrilliantColors.purple,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🚶', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 2),
                Text(
                  '$_stepsCurrent',
                  style: BrilliantTheme.headerStyle(fontSize: 24),
                ),
                Text(
                  '/ $_stepsTarget steps',
                  style: BrilliantTheme.bodyStyle(
                    fontSize: 11,
                    color: BrilliantColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          Row(
            children: [
              _buildMiniStat(
                emoji: '👟',
                label: 'Walked',
                value: '$_stepsCurrent',
                unit: 'steps',
                color: BrilliantColors.purple,
              ),
              _buildStatDivider(),
              _buildMiniStat(
                emoji: '📍',
                label: 'Distance',
                value: '4.8',
                unit: 'km',
                color: BrilliantColors.blue,
              ),
              _buildStatDivider(),
              _buildMiniStat(
                emoji: '⏳',
                label: 'Left',
                value: '$remaining',
                unit: 'steps',
                color: BrilliantColors.amber,
              ),
            ],
          ),

          _buildProgressRow(
              'Step Goal', _stepsCurrent, _stepsTarget, BrilliantColors.purple),
        ],
      ),
    );
  }

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
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            '$label ($unit)',
            style: BrilliantTheme.bodyStyle(
              fontSize: 10,
              color: BrilliantColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 24,
      color: BrilliantColors.surfaceBorder,
    );
  }

  Widget _buildProgressRow(
      String title, int current, int target, Color color) {
    final double pct = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: BrilliantTheme.bodyStyle(fontSize: 12, color: BrilliantColors.textSecondary)),
            Text(
              '${(pct * 100).toInt()}%',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressBar(progress: pct, color: color, height: 8),
      ],
    );
  }

  Widget _buildTasksSection() {
    final completedCount = _tasks.where((t) => t['completed'] == true).length;

    return DashboardGlassCard(
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DAILY CHALLENGES',
                style: BrilliantTheme.badgeStyle(color: BrilliantColors.mint),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BrilliantColors.bgTertiary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: BrilliantColors.surfaceBorder),
                ),
                child: Text(
                  '$completedCount / ${_tasks.length} Done',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: BrilliantColors.mint,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final task = _tasks[index];
              final bool isDone = task['completed'];

              return GestureDetector(
                onTap: () => _toggleTask(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDone
                        ? BrilliantColors.mint.withValues(alpha: 0.1)
                        : BrilliantColors.bgPrimary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDone
                          ? BrilliantColors.mint.withValues(alpha: 0.5)
                          : BrilliantColors.surfaceBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isDone
                              ? BrilliantColors.mint
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDone
                                ? BrilliantColors.mint
                                : BrilliantColors.textMuted,
                            width: 2,
                          ),
                        ),
                        child: isDone
                            ? const Icon(Icons.check, size: 14, color: BrilliantColors.textInverse)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task['title'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDone
                                ? BrilliantColors.textMuted
                                : BrilliantColors.textPrimary,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: BrilliantColors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${task['xp']} XP',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: BrilliantColors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendations() {
    return DashboardGlassCard(
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'AI COACH INSIGHTS',
                style: BrilliantTheme.badgeStyle(color: BrilliantColors.amber),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BrilliantColors.mint.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: BrilliantColors.mint.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hydration Spike',
                        style: BrilliantTheme.titleStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Drink 1.5L more water today to optimize muscle recovery and maintain your streak!',
                        style: BrilliantTheme.bodyStyle(fontSize: 12),
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

  Widget _buildBottomNavigation() {
    final navItems = [
      {'icon': Icons.space_dashboard_rounded, 'label': 'Today'},
      {'icon': Icons.restaurant_menu_rounded, 'label': 'Diet'},
      {'icon': Icons.insights_rounded, 'label': 'Progress'},
      {'icon': Icons.emoji_events_rounded, 'label': 'Rewards'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: BrilliantColors.bgSecondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: BrilliantColors.surfaceBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final isSelected = _currentNavIndex == index;
          final item = navItems[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentNavIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? BrilliantColors.mint.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(color: BrilliantColors.mint.withValues(alpha: 0.4), width: 1.5)
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 20,
                    color: isSelected
                        ? BrilliantColors.mint
                        : BrilliantColors.textMuted,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      item['label'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: BrilliantColors.mint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
