import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/streak_flame.dart';

/// Streak & Rewards content — designed to be embedded inside the DashboardShell.
/// Does NOT have its own Scaffold or bottom nav.
class StreakRewardsContent extends StatefulWidget {
  final VoidCallback onNavigateToLeaderboard;

  const StreakRewardsContent({
    super.key,
    required this.onNavigateToLeaderboard,
  });

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



  // Calendar details
  final int _daysInMonth = 30; // June
  final int _missedDay = 4; // Day 4 missed

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App Bar Header
        SliverToBoxAdapter(child: _buildHeader()),

        // Scrollable content body
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, Layout.navClearance(context)), // Padding at bottom to avoid floating nav bar
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 12),

              // Merged Daily Streak & Streak Calendar Section
              _buildMergedStreakCalendar()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 100.ms),
              const SizedBox(height: 20),

              // Unified XP Progression & Daily Tasks
              _buildXPProgressAndTasksCard()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms),
              const SizedBox(height: 20),



              // Active Achievements Gallery
              _buildSectionLabel('ACHIEVEMENTS'),
              const SizedBox(height: 12),
              _buildAchievementsGallery()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 450.ms),
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
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.bgTertiary,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.accentOrange.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.accentOrange.withValues(alpha: 0.25),
                width: 1,
              ),
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
          // Community Leaderboard Navigation Button
          IconButton(
            onPressed: widget.onNavigateToLeaderboard,
            icon: const Icon(
              Icons.people_alt_rounded,
              color: AppColors.accentCyan,
              size: 22,
            ),
            tooltip: 'Community Leaderboard',
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
  // MERGED STREAK & CALENDAR SECTION
  // ─────────────────────────────────────────────

  Widget _buildMergedStreakCalendar() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Flame icon + Daily Streak text
              Expanded(
                child: Row(
                  children: [
                    const StreakFlame(size: 32),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
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
                          const SizedBox(height: 2),
                          Text(
                            '$_currentStreak Days Active',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right: June 2026 title
              Text(
                'June 2026',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: AppColors.glassBorder,
          ),
          const SizedBox(height: 12),
          
          // Motivational Text
          Text(
            'You\'ve shown up for yourself $_currentStreak days in a row! Keep the flame burning.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Legends Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCalendarLegend(emoji: '🔥', label: 'Streak'),
              const SizedBox(width: 12),
              _buildCalendarLegend(emoji: '✔', label: 'Done'),
              const SizedBox(width: 12),
              _buildCalendarLegend(emoji: '⭕', label: 'Missed'),
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
                  gradient: isStreak
                      ? LinearGradient(
                          colors: [
                            AppColors.accentOrange.withValues(alpha: 0.2),
                            AppColors.accentOrange.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : isMissed
                          ? LinearGradient(
                              colors: [
                                AppColors.accentCoral.withValues(alpha: 0.15),
                                AppColors.accentCoral.withValues(alpha: 0.03),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : isFuture
                              ? null
                              : LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.08),
                                    Colors.white.withValues(alpha: 0.02),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                  color: isFuture ? Colors.transparent : null,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isStreak
                        ? AppColors.accentOrange.withValues(alpha: 0.4)
                        : isMissed
                            ? AppColors.accentCoral.withValues(alpha: 0.3)
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
  // XP & LEVEL PROGRESSION WITH TODAY'S TASKS CARD
  // ─────────────────────────────────────────────

  Widget _buildXPProgressAndTasksCard() {
    final double levelProgress = _currentXP / _xpForNextLevel;
    final int completedCount = _todayTasks.where((t) => t['completed'] == true).length;
    final int remainingCount = _todayTasks.where((t) => t['completed'] == false).length;

    return DashboardGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Level & XP Progression Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level $_level Veteran',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_currentXP / $_xpForNextLevel XP total',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
              color: Colors.white.withValues(alpha: 0.06),
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
          
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: AppColors.glassBorder,
          ),
          const SizedBox(height: 16),

          // 2. Daily Tasks Header & Overview Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'TODAY\'S TASKS',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$completedCount Completed • $remainingCount Remaining',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. Today's Tasks List
          Column(
            children: List.generate(_todayTasks.length, (index) {
              final task = _todayTasks[index];
              final completed = task['completed'] as bool;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: completed
                        ? LinearGradient(
                            colors: [
                              AppColors.accentBlue.withValues(alpha: 0.12),
                              AppColors.accentBlue.withValues(alpha: 0.03),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.06),
                              Colors.white.withValues(alpha: 0.01),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: completed 
                          ? AppColors.accentBlue.withValues(alpha: 0.25) 
                          : AppColors.glassBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon emoji
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: completed
                              ? AppColors.accentBlue.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: completed
                                ? AppColors.accentBlue.withValues(alpha: 0.2)
                                : AppColors.glassBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            task['icon'] as String,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task['title'] as String,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: completed ? AppColors.textSecondary : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                decoration: completed ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${task['xp']} XP per task',
                              style: AppTextStyles.caption.copyWith(
                                color: completed ? AppColors.textTertiary : AppColors.accentBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: completed
                              ? AppColors.accentCyan.withValues(alpha: 0.15)
                              : AppColors.accentOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          completed ? 'Completed' : 'Remaining',
                          style: AppTextStyles.caption.copyWith(
                            color: completed ? AppColors.accentCyan : AppColors.accentOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
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
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.white.withValues(alpha: 0.01),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
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
            AppColors.accentPurple.withValues(alpha: 0.12),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Pulsing Live analysis dot
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.accentPurple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(Icons.auto_awesome, color: AppColors.accentPurple, size: 16),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'AI Consistency Insights',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.accentCyan,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'LIVE ANALYSIS',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accentCyan,
                              fontWeight: FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Metrics grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAIMetric('Consistency', '94%', 'Weekly Score', AppColors.accentCyan),
                    _buildAIMetric('Milestone', '18/21 d', 'Streak Goal', AppColors.accentOrange),
                    _buildAIMetric('Rank', 'Top 13%', 'Global Division', AppColors.accentPurple),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(color: AppColors.glassBorder),
                const SizedBox(height: 14),

                // Observations Bullet List
                _buildInsightBullet('⚡', 'Sunday morning routines have 100% completion rate this month.'),
                const SizedBox(height: 10),
                _buildInsightBullet('🥩', 'Protein goals logged 40% more consistently on workout days.'),
                const SizedBox(height: 14),

                // AI tip recommendation banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Schedule an active recovery walk on Thursday to bridge your mid-week energy dip and secure your streak milestone!',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

  Widget _buildAIMetric(String title, String value, String sub, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightBullet(String icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ),
      ],
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
