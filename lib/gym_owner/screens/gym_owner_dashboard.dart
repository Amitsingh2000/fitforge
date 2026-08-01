import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/gym_dashboard_data.dart';
import '../../models/gym_member.dart';
import '../../models/gym_trainer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import 'add_member_screen.dart';
import 'attendance_screen.dart';
import 'communications_screen.dart';
import 'coupons_screen.dart';
import 'create_gym_screen.dart';
import 'gym_owner_members_tab.dart';
import 'gym_owner_referrals_tab.dart';
import 'gym_owner_analytics_tab.dart';
import 'gym_owner_profile_tab.dart';
import 'leads_screen.dart';
import 'payments_screen.dart';

class GymOwnerDashboard extends ConsumerStatefulWidget {
  const GymOwnerDashboard({super.key});

  @override
  ConsumerState<GymOwnerDashboard> createState() => _GymOwnerDashboardState();
}

class _GymOwnerDashboardState extends ConsumerState<GymOwnerDashboard>
    with TickerProviderStateMixin {
  int _currentNavIndex = 0;

  // Live API State
  GymDashboardToday _todayStats = const GymDashboardToday();
  GymDashboardMonthly _monthlyStats = const GymDashboardMonthly();
  List<GymTrainer> _trainerRoster = [];
  List<GymMember> _memberPreview = [];
  bool _dashboardLoading = true;

  String get _gymName => ref.watch(selectedGymProvider)?.gymName ?? 'FitForge Gym';

  String get _ownerInitials {
    final firstName = ref.watch(authProvider).user?.firstName ?? '';
    return firstName.isNotEmpty ? firstName[0].toUpperCase() : 'G';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    // Ensure active gym is selected or auto-selected
    autoSelectGym(ref);
    final gymId = ref.read(currentGymIdProvider);

    if (gymId == null || gymId.isEmpty) {
      if (mounted) {
        setState(() => _dashboardLoading = false);
      }
      return;
    }

    setState(() => _dashboardLoading = true);

    try {
      final service = ref.read(gymOwnerServiceProvider);
      final today = await service.getTodayDashboard(gymId);
      final monthly = await service.getMonthlyDashboard(gymId);
      final trainers = await service.getTrainersRoster(gymId);
      final members = await service.getMembers(gymId, role: 'MEMBER', limit: 10);

      if (mounted) {
        setState(() {
          _todayStats = today;
          _monthlyStats = monthly;
          _trainerRoster = trainers;
          _memberPreview = members;
          _dashboardLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _dashboardLoading = false);
      }
    }
  }

  // ── Gym data ──
  final String _membershipPlan = 'Pro Plan';
  final int _notificationCount = 3;

  List<Map<String, dynamic>> get _analyticsData => [
        {
          'title': 'Active Members',
          'value': _monthlyStats.activeMembersCount,
          'icon': Icons.directions_run_rounded,
          'color': AppColors.accentCyan,
          'prefix': '',
          'suffix': '',
        },
        {
          'title': 'Today\'s Check-Ins',
          'value': _todayStats.totalCheckIns,
          'icon': Icons.event_available_rounded,
          'color': AppColors.accentCoral,
          'prefix': '',
          'suffix': '',
        },
        {
          'title': 'Monthly Revenue',
          'value': _monthlyStats.totalRevenue,
          'icon': Icons.account_balance_wallet_rounded,
          'color': AppColors.accentBlue,
          'prefix': '₹',
          'suffix': '',
          'isGradient': true,
        },
        {
          'title': 'New Joins Today',
          'value': _todayStats.newJoinsCount,
          'icon': Icons.person_add_rounded,
          'color': AppColors.accentOrange,
          'prefix': '',
          'suffix': '',
        },
        {
          'title': 'Pending Dues',
          'value': _todayStats.totalDuesAmount,
          'icon': Icons.warning_amber_rounded,
          'color': AppColors.accentCoral,
          'prefix': '₹',
          'suffix': '',
        },
        {
          'title': 'Trainers',
          'value': _trainerRoster.length,
          'icon': Icons.fitness_center_rounded,
          'color': AppColors.accentPurple,
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
      'label': 'Payments',
      'icon': Icons.receipt_long_rounded,
      'gradient': [AppColors.accentCyan, const Color(0xFF06B6D4)],
    },
    {
      'label': 'Attendance',
      'icon': Icons.how_to_reg_rounded,
      'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
    },
    {
      'label': 'Leads',
      'icon': Icons.person_search_rounded,
      'gradient': [AppColors.accentOrange, const Color(0xFFF59E0B)],
    },
    {
      'label': 'Coupons',
      'icon': Icons.local_offer_rounded,
      'gradient': [AppColors.accentPurple, const Color(0xFFA855F7)],
    },
    {
      'label': 'Messages',
      'icon': Icons.campaign_rounded,
      'gradient': [const Color(0xFFEC4899), const Color(0xFFBE185D)],
    },
    {
      'label': 'Add Trainer',
      'icon': Icons.fitness_center_rounded,
      'gradient': [AppColors.accentPurple, const Color(0xFFA855F7)],
    },
    {
      'label': 'View Analytics',
      'icon': Icons.insights_rounded,
      'gradient': [AppColors.accentOrange, const Color(0xFFF59E0B)],
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
    final selectedGym = ref.watch(selectedGymProvider);

    if (selectedGym == null && !_dashboardLoading) {
      return Center(
        key: key,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: DashboardGlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storefront_rounded, size: 48, color: AppColors.accentBlue),
                const SizedBox(height: 16),
                Text(
                  'No Gym Profile Found',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set up your gym profile to start managing members and trainers.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreateGymScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Create Gym Now', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CustomScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(child: _buildTopHeader()),

        if (_dashboardLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: LinearProgressIndicator(color: AppColors.accentBlue, minHeight: 2),
            ),
          ),

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionLabel('TRAINERS'),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/gym-owner-trainers'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.accentPurple.withValues(alpha: 0.08),
                        border: Border.all(
                          color: AppColors.accentPurple.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        'View All',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentPurple,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
            onTap: () => Navigator.pushNamed(context, '/gym-owner-join-requests'),
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
        childAspectRatio: 1.38,
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

    return GestureDetector(
      onTap: () {
        if (data['title'] == 'Pending Requests') {
          Navigator.pushNamed(context, '/gym-owner-join-requests');
        }
      },
      child: DashboardGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: color.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Icon(
                    data['icon'] as IconData,
                    color: color,
                    size: 18,
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
                      size: 11,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: isGradient ? 18 : 20,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
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
              final gymId = ref.read(currentGymIdProvider);
              if (gymId == null) return;
              if (action['label'] == 'View Analytics') {
                setState(() => _currentNavIndex = 3);
              } else if (action['label'] == 'Add Trainer') {
                Navigator.pushNamed(context, '/gym-owner-trainers');
              } else if (action['label'] == 'Payments') {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PaymentsScreen(gymId: gymId),
                ));
              } else if (action['label'] == 'Attendance') {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => AttendanceScreen(gymId: gymId),
                ));
              } else if (action['label'] == 'Leads') {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => LeadsScreen(gymId: gymId),
                ));
              } else if (action['label'] == 'Coupons') {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CouponsScreen(gymId: gymId),
                ));
              } else if (action['label'] == 'Messages') {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CommunicationsScreen(gymId: gymId),
                ));
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
    if (_memberPreview.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _buildInlineEmptyRow(
          icon: Icons.people_outline_rounded,
          text: 'No members yet',
          actionLabel: 'Add Member',
          onAction: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddMemberScreen()),
            );
            if (result != null) _loadDashboardData();
          },
        ),
      );
    }
    return SizedBox(
      height: 150,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _memberPreview.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) => _buildMemberCard(_memberPreview[index]),
      ),
    );
  }

  Widget _buildMemberCard(GymMember member) {
    final isActive = member.status.toUpperCase() == 'ACTIVE';
    final statusColor = isActive ? AppColors.accentCyan : AppColors.accentOrange;
    const gradientColors = [AppColors.accentBlue, AppColors.accentCyan];

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      member.firstName.isNotEmpty ? member.firstName[0].toUpperCase() : 'M',
                      style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: statusColor.withValues(alpha: 0.12),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Text(member.status,
                      style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w600, fontSize: 9)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(member.fullName,
                style: AppTextStyles.labelLarge.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              member.planName ?? 'No active plan',
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineEmptyRow({
    required IconData icon,
    required String text,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 18),
        const SizedBox(width: 8),
        Text(text, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
        if (actionLabel != null && onAction != null) ...[
          const Spacer(),
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel,
                style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.w600)),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────
  // TRAINERS HORIZONTAL LIST
  // ─────────────────────────────────────────────

  Widget _buildTrainersHorizontalList() {
    if (_trainerRoster.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _buildInlineEmptyRow(
          icon: Icons.fitness_center_rounded,
          text: 'No trainers yet',
          actionLabel: 'Invite Trainer',
          onAction: () => Navigator.pushNamed(context, '/gym-owner-trainers'),
        ),
      );
    }
    return SizedBox(
      height: 130,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _trainerRoster.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) => _buildTrainerCard(_trainerRoster[index]),
      ),
    );
  }

  Widget _buildTrainerCard(GymTrainer trainer) {
    final statusColor = trainer.status.toUpperCase() == 'ACTIVE' ? AppColors.accentCyan : AppColors.textTertiary;
    const gradientColors = [AppColors.accentPurple, AppColors.accentCoral];

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: SizedBox(
        width: 165,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
                      ),
                      child: Center(
                        child: Text(
                          trainer.name.isNotEmpty ? trainer.name[0].toUpperCase() : 'T',
                          style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
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
                          border: Border.all(color: AppColors.bgPrimary, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(trainer.name,
                style: AppTextStyles.labelLarge.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              trainer.specialization,
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
