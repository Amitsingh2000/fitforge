import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/brilliant_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/streak_flame.dart';

/// Streak & Rewards content — designed to be embedded inside the DashboardShell.
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
  final int _currentStreak = 18;
  final int _currentXP = 4250;
  final int _xpForNextLevel = 5000;
  final int _level = 12;

  final List<Map<String, dynamic>> _todayTasks = [
    {'title': 'Complete Hydration Target', 'xp': 50, 'completed': false, 'icon': '💧'},
    {'title': 'Reach Daily Protein Goal', 'xp': 75, 'completed': false, 'icon': '💪'},
    {'title': 'Perform Planned Workout', 'xp': 100, 'completed': false, 'icon': '🏃'},
    {'title': 'Log 7+ Hours of Sleep', 'xp': 40, 'completed': true, 'icon': '😴'},
  ];

  final int _daysInMonth = 30; // June
  final int _missedDay = 4; // Day 4 missed

  void _toggleTask(int index) {
    setState(() {
      _todayTasks[index]['completed'] = !_todayTasks[index]['completed'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 12),
              _buildMergedStreakCalendar()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.05, end: 0, duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 20),

              _buildXPProgressAndTasksCard()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms),
              const SizedBox(height: 20),

              _buildSectionLabel('ACHIEVEMENTS GALLERY'),
              const SizedBox(height: 10),
              _buildAchievementsGallery()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms),
              const SizedBox(height: 20),

              _buildAIInsightsCard()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: BrilliantColors.amber.withValues(alpha: 0.15),
              border: Border.all(color: BrilliantColors.amber.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Center(
              child: Icon(
                Icons.emoji_events_rounded,
                color: BrilliantColors.amber,
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
                  style: BrilliantTheme.headerStyle(fontSize: 20),
                ),
                const SizedBox(height: 2),
                Text(
                  '"Consistency creates transformation."',
                  style: BrilliantTheme.bodyStyle(fontSize: 11, color: BrilliantColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onNavigateToLeaderboard,
            icon: const Icon(
              Icons.people_alt_rounded,
              color: BrilliantColors.mint,
              size: 22,
            ),
            tooltip: 'Community Leaderboard',
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: BrilliantColors.surfaceBorder, width: 1.5),
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

  Widget _buildSectionLabel(String label) {
    return Text(label, style: BrilliantTheme.badgeStyle(color: BrilliantColors.mint));
  }

  Widget _buildMergedStreakCalendar() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const StreakFlame(size: 32),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY STREAK',
                        style: BrilliantTheme.badgeStyle(color: BrilliantColors.amber),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_currentStreak Days Active',
                        style: BrilliantTheme.headerStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
              const Text(
                'June 2026',
                style: TextStyle(color: BrilliantColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1.5, color: BrilliantColors.surfaceBorder),
          const SizedBox(height: 12),
          Text(
            'You\'ve logged in for $_currentStreak days straight! Keep your flame burning.',
            style: BrilliantTheme.bodyStyle(fontSize: 12),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('🔥', 'Streak'),
              const SizedBox(width: 16),
              _buildLegend('✔', 'Done'),
              const SizedBox(width: 16),
              _buildLegend('⭕', 'Missed'),
            ],
          ),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final day = index + 1;
              final isStreak = day <= _currentStreak && day != _missedDay;
              final isMissed = day == _missedDay;

              return Container(
                decoration: BoxDecoration(
                  color: isStreak
                      ? BrilliantColors.amber.withValues(alpha: 0.15)
                      : isMissed
                          ? BrilliantColors.coral.withValues(alpha: 0.15)
                          : BrilliantColors.bgPrimary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isStreak
                        ? BrilliantColors.amber.withValues(alpha: 0.5)
                        : isMissed
                            ? BrilliantColors.coral.withValues(alpha: 0.5)
                            : BrilliantColors.surfaceBorder,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isStreak
                                ? BrilliantColors.amber
                                : isMissed
                                    ? BrilliantColors.coral
                                    : BrilliantColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          isStreak ? '🔥' : isMissed ? '✕' : '•',
                          style: const TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String emoji, String label) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: BrilliantColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildXPProgressAndTasksCard() {
    final double pct = (_currentXP / _xpForNextLevel).clamp(0.0, 1.0);

    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: BrilliantColors.purple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: BrilliantColors.purple.withValues(alpha: 0.4)),
                    ),
                    child: Text('Level $_level', style: const TextStyle(color: BrilliantColors.purple, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  Text('XP Progression', style: BrilliantTheme.titleStyle(fontSize: 15)),
                ],
              ),
              Text('$_currentXP / $_xpForNextLevel XP', style: const TextStyle(color: BrilliantColors.amber, fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(color: BrilliantColors.bgTertiary, borderRadius: BorderRadius.circular(4)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct,
              child: Container(decoration: BoxDecoration(color: BrilliantColors.amber, borderRadius: BorderRadius.circular(4))),
            ),
          ),
          const SizedBox(height: 20),

          Text("TODAY'S TASKS", style: BrilliantTheme.badgeStyle(color: BrilliantColors.mint)),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _todayTasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final task = _todayTasks[index];
              final bool isDone = task['completed'];

              return GestureDetector(
                onTap: () => _toggleTask(index),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDone ? BrilliantColors.mint.withValues(alpha: 0.1) : BrilliantColors.bgPrimary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDone ? BrilliantColors.mint.withValues(alpha: 0.5) : BrilliantColors.surfaceBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isDone ? BrilliantColors.mint : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isDone ? BrilliantColors.mint : BrilliantColors.textMuted, width: 2),
                        ),
                        child: isDone ? const Icon(Icons.check, size: 14, color: BrilliantColors.textInverse) : null,
                      ),
                      const SizedBox(width: 12),
                      Text(task['icon'], style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          task['title'],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDone ? BrilliantColors.textMuted : BrilliantColors.textPrimary,
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
                        child: Text('+${task['xp']} XP', style: const TextStyle(color: BrilliantColors.amber, fontWeight: FontWeight.w800, fontSize: 11)),
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

  Widget _buildAchievementsGallery() {
    final achievements = [
      {'emoji': '🏆', 'title': 'Fitness Titan', 'sub': 'Reached Level 10'},
      {'emoji': '⚡', 'title': 'Speed Master', 'sub': 'Completed 5 workouts in 1 week'},
      {'emoji': '🎯', 'title': 'Target Ace', 'sub': 'Hit daily macros 10 days'},
      {'emoji': '🌟', 'title': 'Rising Star', 'sub': 'Earned 1000+ XP in 3 days'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: achievements.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final a = achievements[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: BrilliantColors.bgSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BrilliantColors.surfaceBorder, width: 1.5),
          ),
          child: Row(
            children: [
              Text(a['emoji']!, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      a['title']!,
                      style: const TextStyle(color: BrilliantColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a['sub']!,
                      style: const TextStyle(color: BrilliantColors.textMuted, fontSize: 10),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAIInsightsCard() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('AI CONSISTENCY INSIGHT', style: BrilliantTheme.badgeStyle(color: BrilliantColors.amber)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your streak consistency score is 96%! You are currently ranked #12 in Division III.',
            style: BrilliantTheme.bodyStyle(fontSize: 13, color: BrilliantColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
