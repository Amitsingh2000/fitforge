import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../widgets/dashboard_glass_card.dart';

/// Leaderboard & Social content — designed to be embedded inside the DashboardShell.
/// Does NOT have its own Scaffold or bottom nav.
class LeaderboardContent extends StatefulWidget {
  final VoidCallback onBack;

  const LeaderboardContent({
    super.key,
    required this.onBack,
  });

  @override
  State<LeaderboardContent> createState() => _LeaderboardContentState();
}

class _LeaderboardContentState extends State<LeaderboardContent> {
  final int _currentXP = 4250;

  // Leaderboard data with avatar URLs
  late final List<Map<String, dynamic>> _ranking = [
    {
      'rank': 1,
      'name': 'Marcus Vance',
      'xp': '4,980 XP',
      'isUser': false,
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200'
    },
    {
      'rank': 2,
      'name': 'Sarah K.',
      'xp': '4,750 XP',
      'isUser': false,
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200'
    },
    {
      'rank': 3,
      'name': 'Alex Rivera',
      'xp': '4,410 XP',
      'isUser': false,
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200'
    },
    {
      'rank': 4,
      'name': 'You',
      'xp': '$_currentXP XP',
      'isUser': true,
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'
    },
    {
      'rank': 5,
      'name': 'Dave Miller',
      'xp': '3,990 XP',
      'isUser': false,
      'avatar': 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&q=80&w=200'
    },
  ];

  // Interactive Activity Feed data
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

  void _toggleCheer(int index) {
    setState(() {
      final wasCheered = _activities[index]['cheered'] as bool;
      _activities[index]['cheered'] = !wasCheered;
      _activities[index]['cheers'] = (_activities[index]['cheers'] as int) + (wasCheered ? -1 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
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
              _buildLeaderboardSection()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 100.ms),
              const SizedBox(height: 20),

              // Monthly Challenge Card
              _buildMonthlyChallengeCard()
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

  Widget _buildLeaderboardSection() {
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
                  'Weekly Rankings',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Global Division III',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Top 3 Podium
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd Place
              _buildPodiumItem(
                rank: 2,
                name: 'Sarah K.',
                xp: '4,750 XP',
                avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200',
                pedestalHeight: 50,
                color: Colors.grey.shade400,
              ),

              // 1st Place
              _buildPodiumItem(
                rank: 1,
                name: 'Marcus V.',
                xp: '4,980 XP',
                avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200',
                pedestalHeight: 75,
                color: const Color(0xFFFFD700), // Gold
                hasCrown: true,
              ),

              // 3rd Place
              _buildPodiumItem(
                rank: 3,
                name: 'Alex R.',
                xp: '4,410 XP',
                avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
                pedestalHeight: 38,
                color: const Color(0xFFCD7F32), // Bronze
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: AppColors.glassBorder),
          const SizedBox(height: 12),

          // Remaining Leaderboard List
          Column(
            children: _ranking.map((user) {
              final isUser = user['isUser'] as bool;
              final rankNum = user['rank'] as int;

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
                        '#$rankNum',
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
                          image: NetworkImage(user['avatar'] as String),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: isUser ? AppColors.accentBlue.withValues(alpha: 0.5) : AppColors.glassBorder,
                          width: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user['name'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                          color: isUser ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
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
