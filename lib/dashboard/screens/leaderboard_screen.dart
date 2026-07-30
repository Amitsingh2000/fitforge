import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/brilliant_theme.dart';
import '../widgets/dashboard_glass_card.dart';

/// Leaderboard & Social content — designed to be embedded inside the DashboardShell.
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
        SliverToBoxAdapter(child: _buildHeader()),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 12),
              _buildLeaderboardSection()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.05, end: 0, duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 20),

              _buildMonthlyChallengeCard()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms),
              const SizedBox(height: 20),

              _buildSectionLabel('COMMUNITY ACTIVITY'),
              const SizedBox(height: 10),

              _buildActivityFeed()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms),
              const SizedBox(height: 20),
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
          GestureDetector(
            onTap: widget.onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: BrilliantColors.bgSecondary,
                border: Border.all(color: BrilliantColors.surfaceBorder, width: 1.5),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: BrilliantColors.textPrimary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: BrilliantColors.mint.withValues(alpha: 0.15),
              border: Border.all(color: BrilliantColors.mint.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Center(
              child: Icon(
                Icons.people_alt_rounded,
                color: BrilliantColors.mint,
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
                  'Community & League',
                  style: BrilliantTheme.headerStyle(fontSize: 20),
                ),
                const SizedBox(height: 2),
                Text(
                  'Compete and cheer with athletes worldwide',
                  style: BrilliantTheme.bodyStyle(fontSize: 11, color: BrilliantColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, style: BrilliantTheme.badgeStyle(color: BrilliantColors.mint));
  }

  Widget _buildLeaderboardSection() {
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
              Text('Weekly Standings', style: BrilliantTheme.titleStyle(fontSize: 15)),
              const Text('Global Division III', style: TextStyle(color: BrilliantColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildPodiumItem(2, 'Sarah K.', '4,750 XP', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200', 50, Colors.grey.shade400, false),
              _buildPodiumItem(1, 'Marcus V.', '4,980 XP', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200', 75, BrilliantColors.amber, true),
              _buildPodiumItem(3, 'Alex R.', '4,410 XP', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200', 38, const Color(0xFFCD7F32), false),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1.5, color: BrilliantColors.surfaceBorder),
          const SizedBox(height: 12),

          Column(
            children: _ranking.map((user) {
              final isUser = user['isUser'] as bool;
              final rankNum = user['rank'] as int;

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isUser ? BrilliantColors.mint.withValues(alpha: 0.15) : BrilliantColors.bgPrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUser ? BrilliantColors.mint.withValues(alpha: 0.5) : BrilliantColors.surfaceBorder,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        '#$rankNum',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isUser ? BrilliantColors.mint : BrilliantColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(user['avatar'] as String),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user['name'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isUser ? BrilliantColors.mint : BrilliantColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      user['xp'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: BrilliantColors.amber,
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

  Widget _buildPodiumItem(int rank, String name, String xp, String avatarUrl, double height, Color color, bool hasCrown) {
    return Column(
      children: [
        if (hasCrown) const Text('👑', style: TextStyle(fontSize: 18)),
        CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatarUrl)),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: BrilliantColors.textPrimary)),
        Text(xp, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text('#$rank', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildMonthlyChallengeCard() {
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
              Text('June Endurance Challenge', style: BrilliantTheme.titleStyle(fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BrilliantColors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('+500 XP', style: TextStyle(color: BrilliantColors.amber, fontWeight: FontWeight.w800, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Complete 25 active workouts this month', style: BrilliantTheme.bodyStyle(fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('18 / 25 Days', style: TextStyle(color: BrilliantColors.mint, fontWeight: FontWeight.w800, fontSize: 11)),
              Text('7 days remaining', style: TextStyle(color: BrilliantColors.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 6,
            decoration: BoxDecoration(color: BrilliantColors.bgTertiary, borderRadius: BorderRadius.circular(3)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 18 / 25,
              child: Container(decoration: BoxDecoration(color: BrilliantColors.mint, borderRadius: BorderRadius.circular(3))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFeed() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final item = _activities[index];
        final bool isCheered = item['cheered'] as bool;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: BrilliantColors.bgSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BrilliantColors.surfaceBorder, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 18, backgroundImage: NetworkImage(item['avatar'] as String)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: BrilliantColors.textPrimary),
                        children: [
                          TextSpan(text: item['name'] as String, style: const TextStyle(fontWeight: FontWeight.w800)),
                          TextSpan(text: ' ${item['action']}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${item['time']} · +${item['xp']} XP', style: TextStyle(color: BrilliantColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BrilliantButton(
                onPressed: () => _toggleCheer(index),
                color: isCheered ? BrilliantColors.mint.withValues(alpha: 0.2) : BrilliantColors.bgTertiary,
                shadowColor: isCheered ? BrilliantColors.mint : BrilliantColors.surfaceBorder,
                textColor: isCheered ? BrilliantColors.mint : BrilliantColors.textMuted,
                borderRadius: 10,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  children: [
                    Text(isCheered ? '👏' : '🙌', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text('${item['cheers']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
