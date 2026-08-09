import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/gym_dashboard_data.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/linear_progress_bar.dart';

class GymOwnerAnalyticsTab extends ConsumerStatefulWidget {
  const GymOwnerAnalyticsTab({super.key});

  @override
  ConsumerState<GymOwnerAnalyticsTab> createState() => _GymOwnerAnalyticsTabState();
}

class _GymOwnerAnalyticsTabState extends ConsumerState<GymOwnerAnalyticsTab> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'This Year'];

  bool _loading = true;
  List<GrowthPoint> _growthData = [];
  GymDashboardProgress _progressData = const GymDashboardProgress();
  GymSubscriptionUsage _subscriptionUsage = const GymSubscriptionUsage();
  GymDashboardMonthly _monthlyData = const GymDashboardMonthly();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAnalytics());
  }

  Future<void> _loadAnalytics() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null || gymId.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);

    try {
      final service = ref.read(gymOwnerServiceProvider);
      final results = await Future.wait([
        service.getDashboardGrowth(gymId),
        service.getDashboardProgress(gymId),
        service.getSubscriptionUsage(gymId),
        service.getMonthlyDashboard(gymId),
      ]);

      if (mounted) {
        setState(() {
          _growthData = results[0] as List<GrowthPoint>;
          _progressData = results[1] as GymDashboardProgress;
          _subscriptionUsage = results[2] as GymSubscriptionUsage;
          _monthlyData = results[3] as GymDashboardMonthly;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Fallback revenue chart data if empty
  List<Map<String, dynamic>> get _revenueData => [
        {'month': 'Jan', 'value': 3.2},
        {'month': 'Feb', 'value': 3.5},
        {'month': 'Mar', 'value': 3.8},
        {'month': 'Apr', 'value': 4.1},
        {'month': 'May', 'value': 4.5},
        {'month': 'Jun', 'value': 4.8},
        {'month': 'Jul', 'value': _monthlyData.totalRevenue > 0 ? (_monthlyData.totalRevenue / 100000.0) : 5.1},
      ];

  // Membership growth data from API or fallback
  List<Map<String, dynamic>> get _membershipGrowth {
    if (_growthData.isNotEmpty) {
      return _growthData.map((g) => {'month': g.month, 'value': g.memberCount}).toList();
    }
    return [
      {'month': 'Jan', 'value': 180},
      {'month': 'Feb', 'value': 195},
      {'month': 'Mar', 'value': 208},
      {'month': 'Apr', 'value': 220},
      {'month': 'May', 'value': 232},
      {'month': 'Jun', 'value': 241},
      {'month': 'Jul', 'value': _progressData.activeMembers > 0 ? _progressData.activeMembers : 248},
    ];
  }

  List<Map<String, dynamic>> get _weeklyAttendance => [
        {'day': 'Mon', 'value': 0.85},
        {'day': 'Tue', 'value': 0.78},
        {'day': 'Wed', 'value': 0.92},
        {'day': 'Thu', 'value': 0.70},
        {'day': 'Fri', 'value': 0.88},
        {'day': 'Sat', 'value': 0.95},
        {'day': 'Sun', 'value': 0.55},
      ];

  List<Map<String, dynamic>> get _planDistribution {
    final total = _subscriptionUsage.total;
    if (total > 0) {
      return [
        {
          'plan': 'Premium Tier',
          'count': _subscriptionUsage.premiumCount,
          'percent': _subscriptionUsage.premiumCount / total,
          'color': AppColors.accentBlue,
        },
        {
          'plan': 'Trial Full',
          'count': _subscriptionUsage.trialFullCount,
          'percent': _subscriptionUsage.trialFullCount / total,
          'color': AppColors.accentPurple,
        },
        {
          'plan': 'Trial Limited',
          'count': _subscriptionUsage.trialLimitedCount,
          'percent': _subscriptionUsage.trialLimitedCount / total,
          'color': AppColors.accentCyan,
        },
        {
          'plan': 'Free Tier',
          'count': _subscriptionUsage.freeCount,
          'percent': _subscriptionUsage.freeCount / total,
          'color': AppColors.accentOrange,
        },
      ];
    }

    return [
      {
        'plan': 'Premium',
        'count': 98,
        'percent': 0.40,
        'color': AppColors.accentBlue,
      },
      {
        'plan': 'Standard',
        'count': 86,
        'percent': 0.35,
        'color': AppColors.accentPurple,
      },
      {
        'plan': 'Basic',
        'count': 64,
        'percent': 0.25,
        'color': AppColors.accentCyan,
      },
    ];
  }

  List<Map<String, dynamic>> get _topMetrics => [
        {
          'title': '7-Day Check-in Rate',
          'value': '${_progressData.checkInRate7dPercent > 0 ? _progressData.checkInRate7dPercent.toStringAsFixed(0) : 88}%',
          'change': '+12%',
          'isUp': true,
          'icon': Icons.trending_up_rounded,
          'color': AppColors.accentCyan,
        },
        {
          'title': 'Active Members',
          'value': '${_progressData.activeMembers > 0 ? _progressData.activeMembers : _monthlyData.activeMembersCount}',
          'change': '+5%',
          'isUp': true,
          'icon': Icons.directions_run_rounded,
          'color': AppColors.accentBlue,
        },
        {
          'title': 'Inactive Members',
          'value': '${_progressData.inactiveMembers}',
          'change': '-2%',
          'isUp': false,
          'icon': Icons.person_off_rounded,
          'color': AppColors.accentCoral,
        },
        {
          'title': 'Monthly Renewals',
          'value': '${_monthlyData.renewalsCount}',
          'change': '+3%',
          'isUp': true,
          'icon': Icons.autorenew_rounded,
          'color': AppColors.accentPurple,
        },
      ];

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadAnalytics,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analytics',
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your gym\'s performance & engagement metrics',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.05, end: 0, duration: 500.ms),
                ),

                // Period selector
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      children: _periods.map((period) {
                        final isSelected = period == _selectedPeriod;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPeriod = period),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: isSelected
                                    ? AppColors.accentBlue.withValues(alpha: 0.15)
                                    : AppColors.glassBg,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accentBlue.withValues(alpha: 0.4)
                                      : AppColors.glassBorder,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                period,
                                style: AppTextStyles.caption.copyWith(
                                  color: isSelected
                                      ? AppColors.accentBlue
                                      : AppColors.textSecondary,
                                  fontWeight:
                                      isSelected ? FontWeight.w600 : FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 100.ms),
                ),

                // Top metrics row
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 106,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _topMetrics.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final metric = _topMetrics[index];
                        return _buildTopMetricCard(metric);
                      },
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 150.ms)
                      .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 150.ms),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Revenue chart
                      _buildSectionLabel('REVENUE TREND'),
                      const SizedBox(height: 12),
                      _buildRevenueChart()
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 250.ms)
                          .slideY(
                              begin: 0.05, end: 0, duration: 500.ms, delay: 250.ms),
                      const SizedBox(height: 24),

                      // Membership growth
                      _buildSectionLabel('MEMBERSHIP GROWTH'),
                      const SizedBox(height: 12),
                      _buildMembershipGrowthChart()
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 350.ms)
                          .slideY(
                              begin: 0.05, end: 0, duration: 500.ms, delay: 350.ms),
                      const SizedBox(height: 24),

                      // Trainer Progress & Utilization (from GET /dashboard/progress)
                      if (_progressData.byTrainer.isNotEmpty) ...[
                        _buildSectionLabel('TRAINER ENGAGEMENT & UTILIZATION'),
                        const SizedBox(height: 12),
                        _buildTrainerProgressList(),
                        const SizedBox(height: 24),
                      ],

                      // Weekly attendance heatmap
                      _buildSectionLabel('WEEKLY ATTENDANCE'),
                      const SizedBox(height: 12),
                      _buildWeeklyAttendanceChart()
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 450.ms)
                          .slideY(
                              begin: 0.05, end: 0, duration: 500.ms, delay: 450.ms),
                      const SizedBox(height: 24),

                      // Subscription usage / Plan distribution
                      _buildSectionLabel('SUBSCRIPTION TIER DISTRIBUTION'),
                      const SizedBox(height: 12),
                      _buildPlanDistribution()
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 550.ms)
                          .slideY(
                              begin: 0.05, end: 0, duration: 500.ms, delay: 550.ms),
                    ]),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: AppColors.primaryGradient,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildTopMetricCard(Map<String, dynamic> metric) {
    final color = metric['color'] as Color;
    return DashboardGlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 16,
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(metric['icon'] as IconData, color: color, size: 16),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: (metric['isUp'] as bool)
                        ? AppColors.accentCyan.withValues(alpha: 0.1)
                        : AppColors.accentCoral.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    metric['change'] as String,
                    style: AppTextStyles.caption.copyWith(
                      color: (metric['isUp'] as bool)
                          ? AppColors.accentCyan
                          : AppColors.accentCoral,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              metric['value'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              metric['title'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerProgressList() {
    return Column(
      children: _progressData.byTrainer.map((t) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.glassBg,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(t.trainerName, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                  Text('${t.checkInRatePercent.toStringAsFixed(0)}% check-in rate',
                      style: AppTextStyles.caption.copyWith(color: AppColors.accentCyan, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressBar(
                progress: (t.checkInRatePercent / 100).clamp(0.0, 1.0),
                color: AppColors.accentBlue,
              ),
              const SizedBox(height: 6),
              Text('Session pack utilization: ${t.avgSessionUtilizationPercent.toStringAsFixed(0)}%',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Revenue Chart ──
  Widget _buildRevenueChart() {
    final maxVal = _revenueData
        .map((e) => e['value'] as double)
        .reduce((a, b) => a > b ? a : b);

    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '₹${(_monthlyData.totalRevenue > 0 ? _monthlyData.totalRevenue : 480000).toString()}',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.accentCyan.withValues(alpha: 0.1),
                ),
                child: Text(
                  '+18% vs last month',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentCyan,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _revenueData.map((data) {
                final height = (data['value'] as double) / maxVal;
                final isLast = data == _revenueData.last;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: 100 * height,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: isLast
                                ? const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.accentBlue,
                                      AppColors.accentCyan,
                                    ],
                                  )
                                : null,
                            color: isLast
                                ? null
                                : AppColors.accentBlue.withValues(alpha: 0.2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['month'] as String,
                          style: AppTextStyles.caption.copyWith(
                            color: isLast
                                ? AppColors.accentBlue
                                : AppColors.textTertiary,
                            fontWeight:
                                isLast ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Membership Growth Chart ──
  Widget _buildMembershipGrowthChart() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
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
                    '${_membershipGrowth.last['value']} Members',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Total enrolled gym members',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.group_rounded,
                color: AppColors.accentPurple.withValues(alpha: 0.8),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._membershipGrowth.take(5).map((item) {
            final double percent =
                (item['value'] as int) / (_membershipGrowth.last['value'] as int);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      item['month'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: LinearProgressBar(
                      progress: percent,
                      color: AppColors.accentPurple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${item['value']}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Weekly Attendance ──
  Widget _buildWeeklyAttendanceChart() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Peak Days',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Saturday is highest (95%)',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentCyan,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weeklyAttendance.map((item) {
              final val = item['value'] as double;
              final isPeak = val >= 0.9;
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.glassBg,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          height: 80 * val,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            gradient: isPeak
                                ? const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.accentCyan,
                                      AppColors.accentBlue,
                                    ],
                                  )
                                : null,
                            color: isPeak
                                ? null
                                : AppColors.accentBlue.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['day'] as String,
                    style: AppTextStyles.caption.copyWith(
                      color: isPeak
                          ? AppColors.accentCyan
                          : AppColors.textTertiary,
                      fontWeight: isPeak ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Plan Distribution ──
  Widget _buildPlanDistribution() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Membership Tier Breakdown',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ..._planDistribution.map((item) {
            final color = item['color'] as Color;
            final percent = item['percent'] as double;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item['plan'] as String,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${item['count']} (${(percent * 100).toStringAsFixed(0)}%)',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressBar(
                    progress: percent,
                    color: color,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
