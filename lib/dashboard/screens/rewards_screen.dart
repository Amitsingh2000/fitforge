import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/streak_flame.dart';

/// Streak & Rewards content — designed to be embedded inside the DashboardShell.
/// Does NOT have its own Scaffold or bottom nav.
class StreakRewardsContent extends StatefulWidget {
  const StreakRewardsContent({super.key});

  @override
  State<StreakRewardsContent> createState() => _StreakRewardsContentState();
}

class _StreakRewardsContentState extends State<StreakRewardsContent> {
  // Gamification state
  int _currentStreak = 18;
  int _currentXP = 4250;
  final int _xpForNextLevel = 5000;
  final int _level = 12;

  // Checklist tasks state
  final List<Map<String, dynamic>> _todayTasks = [
    {'title': 'Complete Hydration Target', 'xp': 50, 'completed': false, 'icon': '💧'},
    {'title': 'Reach Daily Protein Goal', 'xp': 75, 'completed': false, 'icon': '💪'},
    {'title': 'Perform Planned Workout', 'xp': 100, 'completed': false, 'icon': '🏃'},
    {'title': 'Log 7+ Hours of Sleep', 'xp': 40, 'completed': true, 'icon': '😴'},
  ];

  // Reward Store items
  final List<Map<String, dynamic>> _storeItems = [
    {'title': 'Cyberpunk Blue Theme', 'cost': 1500, 'type': 'Theme', 'icon': '🎨', 'unlocked': false},
    {'title': 'Neon Glow Avatar Frame', 'cost': 800, 'type': 'Frame', 'icon': '👑', 'unlocked': false},
    {'title': 'Streak Freeze Shield', 'cost': 500, 'type': 'Powerup', 'icon': '🛡️', 'unlocked': false},
    {'title': 'Advanced Metabolism Chart', 'cost': 2000, 'type': 'Feature', 'icon': '📈', 'unlocked': false},
  ];

  // Calendar details
  final int _daysInMonth = 30; // June
  final int _missedDay = 4; // Day 4 missed

  void _toggleTask(int index) {
    final wasCompleted = _todayTasks[index]['completed'] as bool;
    final xp = _todayTasks[index]['xp'] as int;

    setState(() {
      _todayTasks[index]['completed'] = !wasCompleted;
      if (!wasCompleted) {
        _currentXP += xp;
      } else {
        _currentXP -= xp;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(_todayTasks[index]['completed'] ? '🎉 Task complete! ' : 'Task reset! '),
            Text(
              _todayTasks[index]['completed'] ? '+$xp XP Earned' : '-$xp XP',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentBlue),
            ),
          ],
        ),
        backgroundColor: AppColors.bgSecondary,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _redeemReward(int index) {
    final item = _storeItems[index];
    final cost = item['cost'] as int;

    if (item['unlocked']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item['title']} is already unlocked!'),
          backgroundColor: AppColors.bgSecondary,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_currentXP >= cost) {
      setState(() {
        _currentXP -= cost;
        item['unlocked'] = true;
      });

      // Celebration popup
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: DashboardGlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  'Reward Redeemed!',
                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'You successfully unlocked ${item['title']}!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Awesome',
                      style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient XP! You need ${cost - _currentXP} more XP.'),
          backgroundColor: AppColors.accentCoral.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App Bar Header
        SliverToBoxAdapter(child: _buildHeader()),

        // Scrollable content body
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 130), // Padding at bottom to avoid floating nav bar
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 12),

              // Hero Streak Section
              _buildHeroStreak()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 100.ms),
              const SizedBox(height: 20),

              // Habit Streak Calendar
              _buildSectionLabel('STREAK CALENDAR'),
              const SizedBox(height: 12),
              _buildCalendarCard()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms),
              const SizedBox(height: 20),

              // Next Milestone Indicator
              _buildMilestoneCard()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 250.ms),
              const SizedBox(height: 20),

              // XP & Level Progression System
              _buildSectionLabel('PROGRESSION LEVEL'),
              const SizedBox(height: 12),
              _buildXPProgressCard()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms),
              const SizedBox(height: 20),

              // Today's Reward Tasks Checklist
              _buildSectionLabel('EARN XP TODAY'),
              const SizedBox(height: 12),
              _buildTodayTasksSection()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 350.ms),
              const SizedBox(height: 20),

              // Monthly Challenge Card
              _buildMonthlyChallengeCard()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms),
              const SizedBox(height: 20),

              // Active Achievements Gallery
              _buildSectionLabel('ACHIEVEMENTS'),
              const SizedBox(height: 12),
              _buildAchievementsGallery()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 450.ms),
              const SizedBox(height: 20),

              // Next Badges Progression
              _buildSectionLabel('UNLOCK NEXT'),
              const SizedBox(height: 12),
              _buildLockedAchievements()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms),
              const SizedBox(height: 20),

              // XP Rewards Store
              _buildSectionLabel('REWARD STORE'),
              const SizedBox(height: 12),
              _buildRewardStore()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 550.ms),
              const SizedBox(height: 20),

              // Leaderboard preview
              _buildSectionLabel('COMMUNITY RANKINGS'),
              const SizedBox(height: 12),
              _buildLeaderboardPreview()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 600.ms),
              const SizedBox(height: 20),

              // AI Insights
              _buildAIInsightsCard()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 650.ms),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.accentOrange.withValues(alpha: 0.12),
            ),
            child: const Center(
              child: Icon(
                Icons.emoji_events_rounded,
                color: AppColors.accentOrange,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Streak & Rewards',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '"Consistency creates transformation."',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          // Notification Icon
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
          // Profile avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.glassBorder, width: 1.5),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HERO STREAK SECTION
  // ─────────────────────────────────────────────

  Widget _buildHeroStreak() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY STREAK',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_currentStreak Days Active',
                    style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 28),
                  ),
                ],
              ),
              const StreakFlame(size: 40),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'You\'ve shown up for yourself $_currentStreak days in a row. Excellent commitment to your goals!',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Streak timeline indicator (last 5 days)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final daysAgo = 4 - index;
              final dayNum = DateTime.now().subtract(Duration(days: daysAgo)).day;
              final isToday = daysAgo == 0;
              final completed = daysAgo != 3; // Simulate one missed day 3 days ago

              return Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.accentOrange.withValues(alpha: 0.15)
                      : completed
                          ? AppColors.bgSecondary
                          : AppColors.accentCoral.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isToday
                        ? AppColors.accentOrange.withValues(alpha: 0.4)
                        : completed
                            ? AppColors.glassBorder
                            : AppColors.accentCoral.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Day $dayNum',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 9,
                        color: isToday ? AppColors.accentOrange : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      completed ? '🔥' : '⭕',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HABIT STREAK CALENDAR
  // ─────────────────────────────────────────────

  Widget _buildCalendarCard() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'June 2026',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _buildCalendarLegend(emoji: '🔥', label: 'Streak'),
                  const SizedBox(width: 10),
                  _buildCalendarLegend(emoji: '✔', label: 'Done'),
                  const SizedBox(width: 10),
                  _buildCalendarLegend(emoji: '⭕', label: 'Missed'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Calendar Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final day = index + 1;
              final isStreak = day <= _currentStreak && day != _missedDay;
              final isMissed = day == _missedDay;
              final isFuture = day > _currentStreak;

              return Container(
                decoration: BoxDecoration(
                  color: isStreak
                      ? AppColors.accentOrange.withValues(alpha: 0.12)
                      : isMissed
                          ? AppColors.accentCoral.withValues(alpha: 0.08)
                          : isFuture
                              ? Colors.transparent
                              : AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isStreak
                        ? AppColors.accentOrange.withValues(alpha: 0.3)
                        : isMissed
                            ? AppColors.accentCoral.withValues(alpha: 0.2)
                            : AppColors.glassBorder,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: AppTextStyles.caption.copyWith(
                          color: isFuture
                              ? AppColors.textTertiary
                              : isStreak
                                  ? AppColors.accentOrange
                                  : isMissed
                                      ? AppColors.accentCoral
                                      : AppColors.textSecondary,
                          fontWeight: isFuture ? FontWeight.normal : FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      if (!isFuture) ...[
                        const SizedBox(height: 2),
                        Text(
                          isStreak
                              ? '🔥'
                              : isMissed
                                  ? '⭕'
                                  : '✔',
                          style: const TextStyle(fontSize: 8),
                        ),
                      ],
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

  Widget _buildCalendarLegend({required String emoji, required String label}) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 9, color: AppColors.textSecondary)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // NEXT MILESTONE SECTION
  // ─────────────────────────────────────────────

  Widget _buildMilestoneCard() {
    const int currentStreakVal = 18;
    const int nextMilestoneVal = 21;
    const int remainingDays = nextMilestoneVal - currentStreakVal;
    const double progress = currentStreakVal / nextMilestoneVal;

    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentBlue.withValues(alpha: 0.1),
            ),
            child: const Center(
              child: Icon(Icons.stars_rounded, color: AppColors.accentBlue, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Next Milestone',
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$remainingDays days left',
                      style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Unlocks: 21 Day Consistency Badge',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 5,
                    color: AppColors.bgTertiary,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // XP & LEVEL PROGRESSION CARD
  // ─────────────────────────────────────────────

  Widget _buildXPProgressCard() {
    final double levelProgress = _currentXP / _xpForNextLevel;

    return DashboardGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level $_level Veteran',
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_currentXP / $_xpForNextLevel XP total',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.2)),
                ),
                child: Text(
                  '${_xpForNextLevel - _currentXP} XP to Lvl ${_level + 1}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 8,
              width: double.infinity,
              color: AppColors.bgTertiary,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: levelProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accentBlue, AppColors.accentPurple],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TODAY'S REWARD TASKS CHECKLIST
  // ─────────────────────────────────────────────

  Widget _buildTodayTasksSection() {
    return Column(
      children: List.generate(_todayTasks.length, (index) {
        final task = _todayTasks[index];
        final completed = task['completed'] as bool;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DashboardGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: () => _toggleTask(index),
            borderColor: completed ? AppColors.accentBlue.withValues(alpha: 0.3) : null,
            child: Row(
              children: [
                // Icon emoji
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: completed
                        ? AppColors.accentBlue.withValues(alpha: 0.1)
                        : AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      task['icon'] as String,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['title'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: completed ? AppColors.textSecondary : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          decoration: completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+${task['xp']} XP',
                        style: AppTextStyles.caption.copyWith(
                          color: completed ? AppColors.textTertiary : AppColors.accentBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Custom checkbox
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: completed ? AppColors.accentBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: completed ? AppColors.accentBlue : AppColors.glassBorder,
                      width: 1.5,
                    ),
                  ),
                  child: completed
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────
  // MONTHLY CHALLENGE CARD
  // ─────────────────────────────────────────────

  Widget _buildMonthlyChallengeCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C191B),
            Color(0xFF1B0E10),
          ],
        ),
        border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.25)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentCoral.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'JUNE CHALLENGE',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentCoral,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    Text(
                      '12 Days Remaining',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'June Transformation Challenge',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Complete 25 active workouts this month to unlock the exclusive "Solstice Warrior" badge + 1,000 XP.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: 18 / 25 Days',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentCoral,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '72%',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 5,
                    color: AppColors.bgTertiary,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 18 / 25,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.coralGradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ACTIVE ACHIEVEMENTS GALLERY
  // ─────────────────────────────────────────────

  Widget _buildAchievementsGallery() {
    final earnedBadges = [
      {'emoji': '🔥', 'title': '7 Day Streak', 'sub': 'Met consistency'},
      {'emoji': '⚔️', 'title': '30d Warrior', 'sub': 'Active month'},
      {'emoji': '💪', 'title': 'Protein Master', 'sub': 'Muscle builder'},
      {'emoji': '💧', 'title': 'Hydration Hero', 'sub': 'Fluids optimizer'},
      {'emoji': '⚡', 'title': 'Champ Status', 'sub': 'Task achiever'},
      {'emoji': '🎯', 'title': 'Goal Crusher', 'sub': 'Weight benchmark'},
    ];

    return DashboardGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievement Gallery',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '6 Unlocked',
                style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: earnedBadges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final badge = earnedBadges[index];
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glass-style metallic badge holder
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.03),
                          ],
                        ),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: Center(
                        child: Text(badge['emoji']!, style: const TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      badge['title']!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      badge['sub']!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // NEXT BADGES PROGRESSION
  // ─────────────────────────────────────────────

  Widget _buildLockedAchievements() {
    final locked = [
      {'title': '60 Day Streak', 'target': '18 / 60 Days', 'ratio': 18 / 60, 'icon': '🏆'},
      {'title': 'Complete 100 Workouts', 'target': '45 / 100', 'ratio': 45 / 100, 'icon': '🏋️'},
      {'title': 'Burn 50,000 Calories', 'target': '22,400 / 50k', 'ratio': 224 / 500, 'icon': '🔥'},
      {'title': 'Track Nutrition 90 Days', 'target': '32 / 90 Days', 'ratio': 32 / 90, 'icon': '📝'},
    ];

    return Column(
      children: locked.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DashboardGlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Center(
                    child: Text(
                      item['icon'] as String,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['title'] as String,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            item['target'] as String,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Container(
                          height: 4,
                          color: AppColors.bgTertiary,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: item['ratio'] as double,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.textTertiary.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────
  // XP REWARDS STORE
  // ─────────────────────────────────────────────

  Widget _buildRewardStore() {
    return DashboardGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'XP Rewards Store',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Your Balance: $_currentXP XP',
                  style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _storeItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final item = _storeItems[index];
              final cost = item['cost'] as int;
              final unlocked = item['unlocked'] as bool;

              return GestureDetector(
                onTap: () => _redeemReward(index),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? AppColors.accentBlue.withValues(alpha: 0.05)
                        : AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: unlocked
                          ? AppColors.accentBlue.withValues(alpha: 0.3)
                          : AppColors.glassBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['icon'] as String, style: const TextStyle(fontSize: 18)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.bgTertiary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['type'] as String,
                              style: AppTextStyles.caption.copyWith(fontSize: 8, color: AppColors.textTertiary),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            unlocked ? 'Unlocked ✅' : '$cost XP',
                            style: AppTextStyles.caption.copyWith(
                              color: unlocked ? AppColors.accentBlue : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
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

  // ─────────────────────────────────────────────
  // COMMUNITY RANKINGS LEADERBOARD PREVIEW
  // ─────────────────────────────────────────────

  Widget _buildLeaderboardPreview() {
    final ranking = [
      {'rank': 1, 'name': 'Marcus Vance', 'xp': '4,980 XP', 'isUser': false},
      {'rank': 2, 'name': 'Sarah K.', 'xp': '4,750 XP', 'isUser': false},
      {'rank': 3, 'name': 'Alex Rivera', 'xp': '4,410 XP', 'isUser': false},
      {'rank': 4, 'name': 'You', 'xp': '$_currentXP XP', 'isUser': true},
      {'rank': 5, 'name': 'Dave Miller', 'xp': '3,990 XP', 'isUser': false},
    ];

    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Rankings',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Global Division III',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: ranking.map((user) {
              final isUser = user['isUser'] as bool;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.accentBlue.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isUser ? Border.all(color: AppColors.accentBlue.withValues(alpha: 0.2)) : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '#${user['rank']}',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isUser ? AppColors.accentBlue : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user['name'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                          color: isUser ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      user['xp'] as String,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isUser ? AppColors.textPrimary : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // AI MOTIVATIONAL INSIGHTS
  // ─────────────────────────────────────────────

  Widget _buildAIInsightsCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentPurple.withValues(alpha: 0.1),
            AppColors.accentCyan.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.psychology_rounded, color: AppColors.accentPurple, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Consistency Insights',
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You\'ve improved overall consistency by 22% this month. Keep it up! You are only 3 days away from your next streak milestone, which places you higher than 87% of FitForge users.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper title label
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
