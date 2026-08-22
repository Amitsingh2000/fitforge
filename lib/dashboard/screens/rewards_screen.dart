import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/daily_task.dart';
import '../../models/rewards_overview.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_flow_providers.dart';
import '../../services/gamification_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/member_async_value.dart';
import '../widgets/streak_flame.dart';
import '../widgets/state_views.dart';

/// Streak & Rewards content — designed to be embedded inside the DashboardShell.
/// Does NOT have its own Scaffold or bottom nav.
class StreakRewardsContent extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToLeaderboard;

  const StreakRewardsContent({
    super.key,
    required this.onNavigateToLeaderboard,
  });

  @override
  ConsumerState<StreakRewardsContent> createState() =>
      _StreakRewardsContentState();
}

class _StreakRewardsContentState extends ConsumerState<StreakRewardsContent> {
  bool _checkInBusy = false;

  String get _monthLabel {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.year}';
  }

  Future<void> _dailyCheckIn() async {
    if (_checkInBusy) return;
    setState(() => _checkInBusy = true);
    try {
      await ref.read(gamificationServiceProvider).dailyCheckIn();
      invalidateDailyLoop(ref);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyApiError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _checkInBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final overviewAsync = ref.watch(rewardsOverviewProvider);
    final tasks = ref.watch(todayDashboardProvider).valueOrNull?.tasks ?? const [];

    return MemberAsyncValue<RewardsOverview>(
      value: overviewAsync,
      loadingMessage: 'Loading rewards…',
      onRetry: () => ref.invalidate(rewardsOverviewProvider),
      builder: (overview) => _buildContent(overview, tasks),
    );
  }

  Widget _buildContent(RewardsOverview overview, List<DailyTask> tasks) {
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
              _buildMergedStreakCalendar(overview)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 100.ms),
              const SizedBox(height: 20),

              // Unified XP Progression & Daily Tasks
              _buildXPProgressAndTasksCard(overview, tasks)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms),
              const SizedBox(height: 20),



              // Active Achievements Gallery
              _buildSectionLabel('ACHIEVEMENTS'),
              const SizedBox(height: 12),
              _buildAchievementsGallery(overview.badges)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 450.ms),
              const SizedBox(height: 20),







              // AI Insights
              _buildAIInsightsCard(overview)
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
          Builder(
            builder: (context) {
              final avatarUrl = ref.watch(authProvider).user?.avatarUrl;
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.glassBorder, width: 1.5),
                  image: avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: avatarUrl == null ? AppColors.bgTertiary : null,
                ),
                child: avatarUrl == null
                    ? const Icon(Icons.person_rounded,
                        color: AppColors.textSecondary, size: 20)
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MERGED STREAK & CALENDAR SECTION
  // ─────────────────────────────────────────────

  Widget _buildMergedStreakCalendar(RewardsOverview overview) {
    final board = overview.dailyCheckInBoard;
    final streak = overview.streakDays;
    DailyCheckInDay? todayEntry;
    for (final d in board) {
      if (d.isToday) {
        todayEntry = d;
        break;
      }
    }
    final canCheckIn = todayEntry != null && !todayEntry.claimed;
    final todayClaimed = todayEntry?.claimed ?? false;

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
                            '$streak Days Active',
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
                _monthLabel,
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
            'You\'ve shown up for yourself $streak days in a row! Keep the flame burning.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          if (canCheckIn || _checkInBusy)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _checkInBusy ? null : _dailyCheckIn,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _checkInBusy
                        ? 'Checking in…'
                        : 'Claim Daily Check-In (+${todayEntry?.rewardXp ?? 0} XP)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          else if (todayClaimed)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.accentCyan, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Checked in today',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

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
            itemCount: board.isNotEmpty
                ? board.length
                : DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: board.isNotEmpty ? board.length.clamp(1, 7) : 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              if (board.isNotEmpty) {
                final entry = board[index];
                final isStreak = entry.claimed;
                final isMissed = !entry.claimed && !entry.isToday;
                final isFuture = !entry.claimed && entry.isToday;

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
                      color: entry.isToday
                          ? AppColors.accentCyan.withValues(alpha: 0.5)
                          : isStreak
                              ? AppColors.accentOrange.withValues(alpha: 0.4)
                              : isMissed
                                  ? AppColors.accentCoral.withValues(alpha: 0.3)
                                  : AppColors.glassBorder,
                      width: entry.isToday ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${entry.day}',
                          style: AppTextStyles.caption.copyWith(
                            color: entry.isToday
                                ? AppColors.accentCyan
                                : isStreak
                                    ? AppColors.accentOrange
                                    : isMissed
                                        ? AppColors.accentCoral
                                        : AppColors.textSecondary,
                            fontWeight: entry.isToday || isStreak
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isStreak
                              ? '🔥'
                              : isMissed
                                  ? '⭕'
                                  : entry.isToday
                                      ? '✨'
                                      : '✔',
                          style: const TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final day = index + 1;
              final daysInMonth =
                  DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
              final isStreak = day <= streak;
              final isFuture = day > DateTime.now().day;

              return Container(
                decoration: BoxDecoration(
                  gradient: isStreak && !isFuture
                      ? LinearGradient(
                          colors: [
                            AppColors.accentOrange.withValues(alpha: 0.2),
                            AppColors.accentOrange.withValues(alpha: 0.05),
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
                    color: isStreak && !isFuture
                        ? AppColors.accentOrange.withValues(alpha: 0.4)
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
                                  : AppColors.textSecondary,
                          fontWeight:
                              isFuture ? FontWeight.normal : FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      if (!isFuture && day <= daysInMonth) ...[
                        const SizedBox(height: 2),
                        Text(
                          isStreak ? '🔥' : '✔',
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

  Widget _buildXPProgressAndTasksCard(
    RewardsOverview overview,
    List<DailyTask> tasks,
  ) {
    final currentXp = overview.currentXp;
    final nextLevelXp = overview.nextLevelXp > 0 ? overview.nextLevelXp : 1000;
    final level = overview.level;
    final levelTitle = overview.levelTitle.isNotEmpty
        ? overview.levelTitle
        : 'Level $level';
    final double levelProgress =
        nextLevelXp > 0 ? (currentXp / nextLevelXp).clamp(0.0, 1.0) : 0;
    final completedCount = tasks.where((t) => t.completed).length;
    final remainingCount = tasks.where((t) => !t.completed).length;
    final xpToNext = (nextLevelXp - currentXp).clamp(0, nextLevelXp);

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
                      levelTitle,
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$currentXp / $nextLevelXp XP total',
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
                  '$xpToNext XP to Lvl ${level + 1}',
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
          if (tasks.isEmpty)
            Text(
              'No tasks for today yet.',
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            )
          else
            Column(
              children: List.generate(tasks.length, (index) {
                final task = tasks[index];
                final completed = task.completed;

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
                              '✓',
                              style: TextStyle(
                                fontSize: 14,
                                color: completed
                                    ? AppColors.accentBlue
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: completed
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  decoration:
                                      completed ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${task.xp} XP per task',
                                style: AppTextStyles.caption.copyWith(
                                  color: completed
                                      ? AppColors.textTertiary
                                      : AppColors.accentBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: completed
                                ? AppColors.accentCyan.withValues(alpha: 0.15)
                                : AppColors.accentOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            completed ? 'Completed' : 'Remaining',
                            style: AppTextStyles.caption.copyWith(
                              color: completed
                                  ? AppColors.accentCyan
                                  : AppColors.accentOrange,
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

  Widget _buildAchievementsGallery(List<MemberBadge> badges) {
    final earnedBadges = badges
        .map((b) => {
              'emoji': b.icon ?? '🏅',
              'title': b.name,
              'sub': b.code,
            })
        .toList();

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
                earnedBadges.isEmpty ? 'None yet' : '${earnedBadges.length} Unlocked',
                style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (earnedBadges.isEmpty)
            Text(
              'Complete streaks and tasks to unlock badges.',
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            )
          else
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

  Widget _buildAIInsightsCard(RewardsOverview overview) {
    final streak = overview.streakDays;
    final levelProgress = overview.nextLevelXp > 0
        ? ((overview.currentXp / overview.nextLevelXp) * 100).round()
        : 0;

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
                    _buildAIMetric('Consistency', '$levelProgress%', 'Level Progress', AppColors.accentCyan),
                    _buildAIMetric('Milestone', '$streak d', 'Current Streak', AppColors.accentOrange),
                    _buildAIMetric('Level', '${overview.level}', overview.levelTitle.isNotEmpty ? overview.levelTitle : 'Your Rank', AppColors.accentPurple),
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
