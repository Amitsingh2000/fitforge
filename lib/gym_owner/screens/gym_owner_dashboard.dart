import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/linear_progress_bar.dart';
import '../../dashboard/widgets/radial_progress.dart';
import 'gym_owner_members_tab.dart';
import 'gym_owner_referrals_tab.dart';
import 'gym_owner_analytics_tab.dart';
import 'gym_owner_profile_tab.dart';

class GymOwnerDashboard extends StatefulWidget {
  const GymOwnerDashboard({super.key});

  @override
  State<GymOwnerDashboard> createState() => _GymOwnerDashboardState();
}

class _GymOwnerDashboardState extends State<GymOwnerDashboard>
    with TickerProviderStateMixin {
  int _currentNavIndex = 0;

  // ── Simulated gym data ──
  final String _gymName = 'FitForge Elite Gym';
  final String _ownerInitials = 'AK';
  final String _membershipPlan = 'Pro Plan';
  final int _notificationCount = 3;

  final List<Map<String, dynamic>> _analyticsData = [
    {
      'title': 'Total Members',
      'value': 248,
      'icon': Icons.people_rounded,
      'color': AppColors.accentBlue,
      'prefix': '',
      'suffix': '',
    },
    {
      'title': 'Active Members',
      'value': 196,
      'icon': Icons.directions_run_rounded,
      'color': AppColors.accentCyan,
      'prefix': '',
      'suffix': '',
    },
    {
      'title': 'Trainers',
      'value': 12,
      'icon': Icons.fitness_center_rounded,
      'color': AppColors.accentPurple,
      'prefix': '',
      'suffix': '',
    },
    {
      'title': 'Pending Requests',
      'value': 8,
      'icon': Icons.person_add_rounded,
      'color': AppColors.accentOrange,
      'prefix': '',
      'suffix': '',
    },
    {
      'title': 'Monthly Revenue',
      'value': 482500,
      'icon': Icons.account_balance_wallet_rounded,
      'color': AppColors.accentBlue,
      'prefix': '₹',
      'suffix': '',
      'isGradient': true,
    },
    {
      'title': 'Today\'s Attendance',
      'value': 142,
      'icon': Icons.event_available_rounded,
      'color': AppColors.accentCoral,
      'prefix': '',
      'suffix': '',
    },
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {
      'label': 'Add Member',
      'icon': Icons.person_add_alt_1_rounded,
      'gradient': [AppColors.accentBlue, const Color(0xFF6366F1)],
    },
    {
      'label': 'Add Trainer',
      'icon': Icons.fitness_center_rounded,
      'gradient': [AppColors.accentPurple, const Color(0xFFA855F7)],
    },
    {
      'label': 'Generate Referral',
      'icon': Icons.share_rounded,
      'gradient': [AppColors.accentCyan, const Color(0xFF06B6D4)],
    },
    {
      'label': 'View Analytics',
      'icon': Icons.insights_rounded,
      'gradient': [AppColors.accentOrange, const Color(0xFFF59E0B)],
    },
  ];

  final List<Map<String, dynamic>> _members = [
    {
      'name': 'Rahul Sharma',
      'initials': 'RS',
      'status': 'Active',
      'attendance': 0.92,
      'goal': 'Weight Loss',
      'trainer': 'Coach Anil',
      'progress': 0.78,
      'gradientColors': [AppColors.accentBlue, AppColors.accentCyan],
    },
    {
      'name': 'Priya Patel',
      'initials': 'PP',
      'status': 'Active',
      'attendance': 0.88,
      'goal': 'Muscle Gain',
      'trainer': 'Coach Meera',
      'progress': 0.65,
      'gradientColors': [AppColors.accentPurple, AppColors.accentCoral],
    },
    {
      'name': 'Vikram Singh',
      'initials': 'VS',
      'status': 'Inactive',
      'attendance': 0.45,
      'goal': 'Endurance',
      'trainer': 'Coach Raj',
      'progress': 0.32,
      'gradientColors': [AppColors.accentOrange, AppColors.accentCoral],
    },
    {
      'name': 'Sneha Gupta',
      'initials': 'SG',
      'status': 'Active',
      'attendance': 0.95,
      'goal': 'Flexibility',
      'trainer': 'Coach Anil',
      'progress': 0.88,
      'gradientColors': [AppColors.accentCyan, AppColors.accentBlue],
    },
    {
      'name': 'Arjun Reddy',
      'initials': 'AR',
      'status': 'Active',
      'attendance': 0.76,
      'goal': 'Strength',
      'trainer': 'Coach Meera',
      'progress': 0.55,
      'gradientColors': [AppColors.accentBlue, AppColors.accentPurple],
    },
  ];

  final List<Map<String, dynamic>> _trainers = [
    {
      'name': 'Coach Anil',
      'initials': 'CA',
      'activeClients': 18,
      'satisfaction': 4.8,
      'retention': 0.94,
      'status': 'Available',
      'gradientColors': [AppColors.accentBlue, const Color(0xFF6366F1)],
    },
    {
      'name': 'Coach Meera',
      'initials': 'CM',
      'activeClients': 22,
      'satisfaction': 4.9,
      'retention': 0.97,
      'status': 'In Session',
      'gradientColors': [AppColors.accentPurple, AppColors.accentCoral],
    },
    {
      'name': 'Coach Raj',
      'initials': 'CR',
      'activeClients': 15,
      'satisfaction': 4.6,
      'retention': 0.88,
      'status': 'Available',
      'gradientColors': [AppColors.accentCyan, AppColors.accentBlue],
    },
    {
      'name': 'Coach Dia',
      'initials': 'CD',
      'activeClients': 12,
      'satisfaction': 4.7,
      'retention': 0.91,
      'status': 'Off Duty',
      'gradientColors': [AppColors.accentOrange, const Color(0xFFF59E0B)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // ── Ambient background glows ──
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
          Positioned(
            top: 200,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentCoral.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Tab content ──
          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildCurrentPage(),
            ),
          ),

          // ── Bottom navigation ──
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
        return const GymOwnerMembersTab(key: ValueKey('members'));
      case 2:
        return const GymOwnerReferralsTab(key: ValueKey('referrals'));
      case 3:
        return GymOwnerAnalyticsTab(key: const ValueKey('analytics'));
      case 4:
        return const GymOwnerProfileTab(key: ValueKey('profile'));
      case 0:
      default:
        return _buildDashboardHome(key: const ValueKey('dashboard_home'));
    }
  }

  // ═══════════════════════════════════════════════
  //  DASHBOARD HOME CONTENT
  // ═══════════════════════════════════════════════

  Widget _buildDashboardHome({Key? key}) {
    return CustomScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(child: _buildTopHeader()),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Analytics cards grid
              _buildSectionLabel('OVERVIEW'),
              const SizedBox(height: 12),
              _buildAnalyticsGrid()
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 100.ms)
                  .slideY(
                      begin: 0.08, end: 0, duration: 600.ms, delay: 100.ms),
              const SizedBox(height: 24),

              // Quick Actions
              _buildSectionLabel('QUICK ACTIONS'),
              const SizedBox(height: 12),
              _buildQuickActions()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 250.ms)
                  .slideY(
                      begin: 0.08, end: 0, duration: 500.ms, delay: 250.ms),
              const SizedBox(height: 24),

              // Members Section
              _buildSectionLabel('MEMBERS'),
              const SizedBox(height: 12),
            ]),
          ),
        ),

        // Members horizontal list (needs full width, outside padding)
        SliverToBoxAdapter(
          child: _buildMembersHorizontalList()
              .animate()
              .fadeIn(duration: 500.ms, delay: 400.ms)
              .slideY(begin: 0.08, end: 0, duration: 500.ms, delay: 400.ms),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSectionLabel('TRAINERS'),
              const SizedBox(height: 12),
            ]),
          ),
        ),

        // Trainers horizontal list
        SliverToBoxAdapter(
          child: _buildTrainersHorizontalList()
              .animate()
              .fadeIn(duration: 500.ms, delay: 550.ms)
              .slideY(begin: 0.08, end: 0, duration: 500.ms, delay: 550.ms),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 130)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // TOP HEADER
  // ─────────────────────────────────────────────

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          // Owner avatar
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
                _ownerInitials,
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Gym name + plan badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _gymName,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentBlue.withValues(alpha: 0.2),
                        AppColors.accentPurple.withValues(alpha: 0.15),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.accentBlue.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _membershipPlan,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
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
                  if (_notificationCount > 0)
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
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ANALYTICS CARDS GRID
  // ─────────────────────────────────────────────

  Widget _buildAnalyticsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemCount: _analyticsData.length,
      itemBuilder: (context, index) {
        final data = _analyticsData[index];
        return _buildAnalyticsCard(data, index);
      },
    );
  }

  Widget _buildAnalyticsCard(Map<String, dynamic> data, int index) {
    final color = data['color'] as Color;
    final isGradient = data['isGradient'] ?? false;

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: color.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Icon(
                    data['icon'] as IconData,
                    color: color,
                    size: 20,
                  ),
                ),
              ),
              // Trend indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.accentCyan.withValues(alpha: 0.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.accentCyan,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '+${(index + 2) * 3}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentCyan,
                        fontWeight: FontWeight.w600,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: data['value'] as int),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  String displayValue;
                  if (data['prefix'] == '₹') {
                    displayValue =
                        '₹${_formatCurrency(value)}';
                  } else {
                    displayValue = '$value';
                  }
                  return Text(
                    displayValue,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: isGradient ? 19 : 22,
                      foreground: isGradient
                          ? (Paint()
                            ..shader = const LinearGradient(
                              colors: [
                                AppColors.accentBlue,
                                Color(0xFF6366F1),
                              ],
                            ).createShader(
                                const Rect.fromLTWH(0, 0, 120, 30)))
                          : null,
                      color: isGradient ? null : AppColors.textPrimary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 2),
              Text(
                data['title'] as String,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int value) {
    if (value >= 100000) {
      final lakhs = value / 100000;
      return '${lakhs.toStringAsFixed(lakhs.truncateToDouble() == lakhs ? 0 : 1)}L';
    } else if (value >= 1000) {
      final thousands = value / 1000;
      return '${thousands.toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  // ─────────────────────────────────────────────
  // QUICK ACTIONS
  // ─────────────────────────────────────────────

  Widget _buildQuickActions() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _quickActions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final action = _quickActions[index];
          final colors = action['gradient'] as List<Color>;
          return GestureDetector(
            onTap: () {
              if (action['label'] == 'View Analytics') {
                setState(() => _currentNavIndex = 3);
              }
            },
            child: Container(
              width: 90,
              decoration: AppDecorations.glassCardWithRadius(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: colors,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors[0].withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        action['icon'] as IconData,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['label'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MEMBERS HORIZONTAL LIST
  // ─────────────────────────────────────────────

  Widget _buildMembersHorizontalList() {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _members.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return _buildMemberCard(_members[index]);
        },
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    final gradientColors = member['gradientColors'] as List<Color>;
    final isActive = member['status'] == 'Active';

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + Status row
            Row(
              children: [
                // Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      member['initials'] as String,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isActive
                        ? AppColors.accentCyan.withValues(alpha: 0.12)
                        : AppColors.accentOrange.withValues(alpha: 0.12),
                    border: Border.all(
                      color: isActive
                          ? AppColors.accentCyan.withValues(alpha: 0.3)
                          : AppColors.accentOrange.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    member['status'] as String,
                    style: AppTextStyles.caption.copyWith(
                      color: isActive
                          ? AppColors.accentCyan
                          : AppColors.accentOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Progress ring
                RadialProgress(
                  progress: member['progress'] as double,
                  size: 28,
                  strokeWidth: 3,
                  progressColor: gradientColors[0],
                  child: Text(
                    '${((member['progress'] as double) * 100).toInt()}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Name
            Text(
              member['name'] as String,
              style: AppTextStyles.labelLarge.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            // Goal + trainer
            Text(
              '${member['goal']} • ${member['trainer']}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // Attendance progress
            Row(
              children: [
                Text(
                  'Attendance',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                Text(
                  '${((member['attendance'] as double) * 100).toInt()}%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressBar(
              progress: member['attendance'] as double,
              color: gradientColors[0],
              height: 4,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TRAINERS HORIZONTAL LIST
  // ─────────────────────────────────────────────

  Widget _buildTrainersHorizontalList() {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _trainers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return _buildTrainerCard(_trainers[index]);
        },
      ),
    );
  }

  Widget _buildTrainerCard(Map<String, dynamic> trainer) {
    final gradientColors = trainer['gradientColors'] as List<Color>;
    final status = trainer['status'] as String;

    Color statusColor;
    switch (status) {
      case 'Available':
        statusColor = AppColors.accentCyan;
        break;
      case 'In Session':
        statusColor = AppColors.accentOrange;
        break;
      default:
        statusColor = AppColors.textTertiary;
    }

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: SizedBox(
        width: 175,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + status dot
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradientColors,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          trainer['initials'] as String,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.bgPrimary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Status pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: statusColor.withValues(alpha: 0.12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Name
            Text(
              trainer['name'] as String,
              style: AppTextStyles.labelLarge.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),

            // Active clients + satisfaction
            Row(
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  color: AppColors.textTertiary,
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  '${trainer['activeClients']} clients',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.star_rounded,
                  color: AppColors.accentOrange,
                  size: 13,
                ),
                const SizedBox(width: 2),
                Text(
                  '${trainer['satisfaction']}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Retention score
            Row(
              children: [
                Text(
                  'Retention',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                Text(
                  '${((trainer['retention'] as double) * 100).toInt()}%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressBar(
              progress: trainer['retention'] as double,
              color: gradientColors[0],
              height: 4,
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
      {'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
      {'icon': Icons.people_rounded, 'label': 'Members'},
      {'icon': Icons.card_giftcard_rounded, 'label': 'Referrals'},
      {'icon': Icons.insights_rounded, 'label': 'Analytics'},
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
