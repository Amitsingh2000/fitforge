import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/leaderboard_entry.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_flow_providers.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/member_async_value.dart';

const _defaultAvatar =
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200';

/// Leaderboard & Social content — designed to be embedded inside the DashboardShell.
/// Does NOT have its own Scaffold or bottom nav.
class LeaderboardContent extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const LeaderboardContent({
    super.key,
    required this.onBack,
  });

  @override
  ConsumerState<LeaderboardContent> createState() => _LeaderboardContentState();
}

class _LeaderboardContentState extends ConsumerState<LeaderboardContent> {
  String _scope = 'GLOBAL';

  // Interactive Activity Feed data (still mock — no API yet)
  final List<Map<String, dynamic>> _activities = [
    {
      'name': 'Marcus Vance',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200',
      'action': 'completed a 45 min HIIT Workout! ⚡',
      'xp': 100,
      'time': '2h ago',
      'cheers': 12,
      'cheered': false,
    },
    {
      'name': 'Sarah K.',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200',
      'action': 'reached a 15-day workout streak milestone! 🔥',
      'xp': 150,
      'time': '4h ago',
      'cheers': 18,
      'cheered': true,
    },
    {
      'name': 'Alex Rivera',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
      'action': 'logged a new Personal Record in Deadlift (140 kg)! 🏋️',
      'xp': 200,
      'time': '5h ago',
      'cheers': 24,
      'cheered': false,
    },
  ];

  String? get _activeGymId {
    final memberships = ref.watch(authProvider).user?.gymMemberships ?? [];
    for (final m in memberships) {
      if (m.status == 'ACTIVE') return m.gymId;
    }
    return null;
  }

  bool get _hasGym => _activeGymId != null;

  String? get _myUserId => ref.watch(authProvider).user?.id;

  LeaderboardQuery get _leaderboardQuery => (
        type: 'XP',
        scope: _scope,
        gymId: _scope == 'GYM' ? _activeGymId : null,
        filter: 'ALL_TIME',
        limit: 50,
      );

  void _toggleCheer(int index) {
    setState(() {
      final wasCheered = _activities[index]['cheered'] as bool;
      _activities[index]['cheered'] = !wasCheered;
      _activities[index]['cheers'] = (_activities[index]['cheers'] as int) + (wasCheered ? -1 : 1);
    });
  }

  bool _scopeInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_scopeInitialized && _activeGymId != null) {
      _scope = 'GYM';
      _scopeInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(leaderboardProvider(_leaderboardQuery));
    final challengesAsync = ref.watch(challengesProvider(_activeGymId));
    final challenge = challengesAsync.valueOrNull?.isNotEmpty == true
        ? challengesAsync.valueOrNull!.first
        : null;

    return MemberAsyncValue<LeaderboardResponse>(
      value: leaderboardAsync,
      loadingMessage: 'Loading leaderboard…',
      onRetry: () => ref.invalidate(leaderboardProvider(_leaderboardQuery)),
      builder: (response) => _buildContent(response, challenge),
    );
  }

  Widget _buildContent(LeaderboardResponse response, Challenge? challenge) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App Bar Header
        SliverToBoxAdapter(child: _buildHeader()),

        // Content body
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, Layout.navClearance(context)), // bottom padding to avoid floating nav bar
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 12),

              // Weekly Rankings Podiums & Leaderboard
              _buildLeaderboardSection(response)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 100.ms),
              const SizedBox(height: 20),

              // Monthly Challenge Card
              if (challenge != null)
                _buildMonthlyChallengeCard(challenge)
              else
                _buildMonthlyChallengeCardPlaceholder()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms),
              const SizedBox(height: 20),

              // Community Activity Feed label
              _buildSectionLabel('COMMUNITY ACTIVITY'),
              const SizedBox(height: 12),

              // Activity Feed Cards
              _buildActivityFeed()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms),
              const SizedBox(height: 20),
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
          // Back Button
          GestureDetector(
            onTap: widget.onBack,
            child: Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 12),
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
              color: AppColors.accentCyan.withValues(alpha: 0.12),
            ),
            child: const Center(
              child: Icon(
                Icons.people_alt_rounded,
                color: AppColors.accentCyan,
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
                  'Community & Social',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Compete and collaborate with friends',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
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
  // LEADERBOARD SECTION WITH PODIUMS
  // ─────────────────────────────────────────────

  Widget _buildLeaderboardSection(LeaderboardResponse response) {
    final entries = response.leaderboard;
    final myRank = response.myRank;
    final myId = _myUserId;
    final scopeLabel = _scope == 'GYM' ? 'Gym Leaderboard' : 'Global Division';

    LeaderboardEntry? first;
    LeaderboardEntry? second;
    LeaderboardEntry? third;
    for (final e in entries) {
      if (e.rank == 1) first = e;
      if (e.rank == 2) second = e;
      if (e.rank == 3) third = e;
    }

    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'XP Rankings',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                scopeLabel,
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          if (_hasGym) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _buildScopeChip('Gym', 'GYM'),
                const SizedBox(width: 8),
                _buildScopeChip('Global', 'GLOBAL'),
              ],
            ),
          ],
          if (myRank != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.2)),
              ),
              child: Text(
                'Your rank: #${myRank.rank} · ${myRank.score} XP',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (entries.length >= 3)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (second != null)
                  _buildPodiumItem(
                    rank: 2,
                    name: second.name,
                    xp: '${second.score} XP',
                    avatarUrl: second.avatarUrl ?? _defaultAvatar,
                    pedestalHeight: 50,
                    color: Colors.grey.shade400,
                  ),
                if (first != null)
                  _buildPodiumItem(
                    rank: 1,
                    name: first.name,
                    xp: '${first.score} XP',
                    avatarUrl: first.avatarUrl ?? _defaultAvatar,
                    pedestalHeight: 75,
                    color: const Color(0xFFFFD700),
                    hasCrown: true,
                  ),
                if (third != null)
                  _buildPodiumItem(
                    rank: 3,
                    name: third.name,
                    xp: '${third.score} XP',
                    avatarUrl: third.avatarUrl ?? _defaultAvatar,
                    pedestalHeight: 38,
                    color: const Color(0xFFCD7F32),
                  ),
              ],
            )
          else if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No rankings yet.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
              ),
            ),
          const SizedBox(height: 24),
          if (entries.isNotEmpty) ...[
            Divider(color: AppColors.glassBorder),
            const SizedBox(height: 12),
            Column(
              children: entries.map((user) {
                final isUser = user.userId == myId;

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.accentBlue.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isUser
                        ? Border.all(color: AppColors.accentBlue.withValues(alpha: 0.2))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '#${user.rank}',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isUser ? AppColors.accentBlue : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(user.avatarUrl ?? _defaultAvatar),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            color: isUser
                                ? AppColors.accentBlue.withValues(alpha: 0.5)
                                : AppColors.glassBorder,
                            width: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isUser ? 'You' : user.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                            color: isUser ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${user.score} XP',
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
        ],
      ),
    );
  }

  Widget _buildScopeChip(String label, String scope) {
    final selected = _scope == scope;
    return GestureDetector(
      onTap: () => setState(() => _scope = scope),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentCyan.withValues(alpha: 0.15)
              : AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? AppColors.accentCyan.withValues(alpha: 0.4)
                : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: selected ? AppColors.accentCyan : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumItem({
    required int rank,
    required String name,
    required String xp,
    required String avatarUrl,
    required double pedestalHeight,
    required Color color,
    bool hasCrown = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Avatar
            Container(
              width: rank == 1 ? 56 : 46,
              height: rank == 1 ? 56 : 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
                image: DecorationImage(
                  image: NetworkImage(avatarUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (hasCrown)
              const Positioned(
                top: -16,
                child: Text('👑', style: TextStyle(fontSize: 16)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          xp,
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 9,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        
        // Pedestal
        Container(
          width: rank == 1 ? 64 : 52,
          height: pedestalHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.35),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: rank == 1 ? 16 : 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // MONTHLY CHALLENGE CARD (Relocated)
  // ─────────────────────────────────────────────

  Widget _buildMonthlyChallengeCard(Challenge challenge) {
    final daysRemaining =
        challenge.endsAt?.difference(DateTime.now()).inDays.clamp(0, 999);
    final progress = challenge.targetValue > 0
        ? (challenge.myProgress / challenge.targetValue).clamp(0.0, 1.0)
        : 0.0;
    final progressPct = (progress * 100).round();

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
                        challenge.scope == 'GYM' ? 'GYM CHALLENGE' : 'ACTIVE CHALLENGE',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentCoral,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    if (daysRemaining != null)
                      Text(
                        '$daysRemaining Days Remaining',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  challenge.title,
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                if (challenge.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    challenge.description!,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
                if (challenge.rewardXp > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Reward: ${challenge.rewardXp} XP',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentCoral,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: ${challenge.myProgress} / ${challenge.targetValue}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentCoral,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$progressPct%',
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
                        widthFactor: progress,
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

  Widget _buildMonthlyChallengeCardPlaceholder() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      child: Text(
        'No active challenges right now.',
        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // COMMUNITY ACTIVITY FEED (Social Page Additions)
  // ─────────────────────────────────────────────

  Widget _buildActivityFeed() {
    return Column(
      children: List.generate(_activities.length, (index) {
        final activity = _activities[index];
        final cheered = activity['cheered'] as bool;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DashboardGlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Friend Avatar
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(activity['avatar'] as String),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                ),
                const SizedBox(width: 12),

                // Post Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            activity['name'] as String,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            activity['time'] as String,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity['action'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Interactive Cheer Button
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _toggleCheer(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: cheered
                                    ? AppColors.accentOrange.withValues(alpha: 0.15)
                                    : AppColors.bgSecondary,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: cheered
                                      ? AppColors.accentOrange.withValues(alpha: 0.4)
                                      : AppColors.glassBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    cheered ? '🔥' : '💪',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    cheered ? 'Cheered!' : 'Cheer',
                                    style: AppTextStyles.caption.copyWith(
                                      color: cheered ? AppColors.accentOrange : AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${activity['cheers']} cheers',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Section Label
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
