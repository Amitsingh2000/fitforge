import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/linear_progress_bar.dart';
import '../../models/gym_dashboard_data.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';

class GymOwnerAnalyticsTab extends ConsumerStatefulWidget {
  const GymOwnerAnalyticsTab({super.key});

  @override
  ConsumerState<GymOwnerAnalyticsTab> createState() => _GymOwnerAnalyticsTabState();
}

class _GymOwnerAnalyticsTabState extends ConsumerState<GymOwnerAnalyticsTab> {
  // Live data (§ owner-flow extension: growth/progress/subscription-usage)
  GymDashboardMonthly _monthlyStats = const GymDashboardMonthly();
  List<GymGrowthPoint> _growthTrend = [];
  GymProgressOverview _progressOverview = const GymProgressOverview();
  GymSubscriptionUsage _subscriptionUsage = const GymSubscriptionUsage();
  bool _liveDataLoading = true;

  List<Map<String, dynamic>> get _revenueData {
    return _monthlyStats.attendanceTrend.take(14).map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      final parsed = DateTime.tryParse('${m['date']}');
      return {
        'month': parsed != null ? '${parsed.day}/${parsed.month}' : 'Day',
        'value': (m['checkIns'] as num?)?.toDouble() ?? 0,
      };
    }).toList();
  }

  List<Map<String, dynamic>> get _weeklyAttendance {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sums = List<double>.filled(7, 0);
    final counts = List<int>.filled(7, 0);
    for (final raw in _monthlyStats.attendanceTrend) {
      final m = Map<String, dynamic>.from(raw as Map);
      final d = DateTime.tryParse('${m['date']}');
      if (d == null) continue;
      final i = d.weekday - 1;
      sums[i] += (m['checkIns'] as num?)?.toDouble() ?? 0;
      counts[i] += 1;
    }
    final peak = sums.fold<double>(0, (a, b) => a > b ? a : b);
    return List.generate(7, (i) {
      final avg = counts[i] == 0 ? 0.0 : sums[i] / counts[i];
      return {
        'day': days[i],
        'value': peak == 0 ? 0.0 : (avg / peak).clamp(0.0, 1.0),
      };
    });
  }

  List<Map<String, dynamic>> get _topMetrics {
    final checkIns = _monthlyStats.attendanceTrend
        .map((raw) {
          final m = Map<String, dynamic>.from(raw as Map);
          return (m['checkIns'] as num?)?.toInt() ?? 0;
        })
        .toList();
    final avgAttendance = checkIns.isEmpty
        ? 0
        : (checkIns.reduce((a, b) => a + b) / checkIns.length).round();
    return [
      {
        'title': 'Avg. Daily Attendance',
        'value': '$avgAttendance',
        'change': '',
        'isUp': true,
        'icon': Icons.trending_up_rounded,
        'color': AppColors.accentCyan,
      },
      {
        'title': 'Member Retention',
        'value': _monthlyStats.retentionRatePercent != null
            ? '${_monthlyStats.retentionRatePercent!.toStringAsFixed(0)}%'
            : '—',
        'change': '',
        'isUp': true,
        'icon': Icons.loyalty_rounded,
        'color': AppColors.accentPurple,
      },
      {
        'title': 'Revenue this month',
        'value': '₹${_monthlyStats.totalRevenue}',
        'change': '',
        'isUp': true,
        'icon': Icons.show_chart_rounded,
        'color': AppColors.accentBlue,
      },
      {
        'title': 'Churn this month',
        'value': '${_monthlyStats.churnCount}',
        'change': '',
        'isUp': false,
        'icon': Icons.trending_down_rounded,
        'color': AppColors.accentCoral,
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLiveData());
  }

  Future<void> _loadLiveData() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) {
      setState(() => _liveDataLoading = false);
      return;
    }
    try {
      final service = ref.read(gymOwnerServiceProvider);
      final results = await Future.wait([
        service.getMonthlyDashboard(gymId),
        service.getGrowthTrend(gymId),
        service.getProgressOverview(gymId),
        service.getSubscriptionUsage(gymId),
      ]);
      if (mounted) {
        setState(() {
          _monthlyStats = results[0] as GymDashboardMonthly;
          _growthTrend = results[1] as List<GymGrowthPoint>;
          _progressOverview = results[2] as GymProgressOverview;
          _subscriptionUsage = results[3] as GymSubscriptionUsage;
          _liveDataLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _liveDataLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
                  'Your gym\'s performance at a glance',
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
          padding: EdgeInsets.fromLTRB(20, 24, 20, Layout.navClearance(context)),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Check-in trend (the backend only tracks a per-day check-in
              // count, not a per-day revenue breakdown — revenue is a single
              // month total, shown in the metric card above instead).
              _buildSectionLabel('CHECK-IN TREND'),
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

              // Weekly attendance heatmap
              _buildSectionLabel('WEEKLY ATTENDANCE'),
              const SizedBox(height: 12),
              _buildWeeklyAttendanceChart()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 450.ms)
                  .slideY(
                      begin: 0.05, end: 0, duration: 500.ms, delay: 450.ms),
              const SizedBox(height: 24),

              // Progress monitoring (attendance/session-based engagement proxy)
              _buildSectionLabel('PROGRESS MONITORING'),
              const SizedBox(height: 12),
              _buildProgressOverview()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 650.ms)
                  .slideY(
                      begin: 0.05, end: 0, duration: 500.ms, delay: 650.ms),
              const SizedBox(height: 24),

              // Subscription usage
              _buildSectionLabel('SUBSCRIPTION USAGE'),
              const SizedBox(height: 12),
              _buildSubscriptionUsage()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 750.ms)
                  .slideY(
                      begin: 0.05, end: 0, duration: 500.ms, delay: 750.ms),
            ]),
          ),
        ),
      ],
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

  // ── Check-in Trend Chart (Bar chart) ──
  Widget _buildRevenueChart() {
    final values = _revenueData.map((e) => e['value'] as double);
    final maxVal = values.fold<double>(1, (a, b) => a > b ? a : b);
    final totalCheckIns = values.fold<double>(0, (a, b) => a + b).round();

    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$totalCheckIns',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'check-ins this month · by day',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_revenueData.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No check-in trend yet this month.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              ),
            )
          else
            SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _revenueData.map((data) {
                final height = (data['value'] as double) / maxVal;
                final isLast =
                    data == _revenueData.last;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: height),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return Container(
                              height: 100 * value,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: isLast
                                    ? AppColors.primaryGradient
                                    : null,
                                color: isLast
                                    ? null
                                    : AppColors.accentBlue
                                        .withValues(alpha: 0.25),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['month'] as String,
                          style: AppTextStyles.caption.copyWith(
                            color: isLast
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                            fontSize: 10,
                            fontWeight:
                                isLast ? FontWeight.w600 : FontWeight.w500,
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

  // ── Membership Growth (Line-like bar chart) — real data from `dashboard/growth` ──
  Widget _buildMembershipGrowthChart() {
    if (_liveDataLoading) {
      return const DashboardGlassCard(
        padding: EdgeInsets.all(20),
        borderRadius: 18,
        child: SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator(color: AppColors.accentBlue, strokeWidth: 2)),
        ),
      );
    }
    if (_growthTrend.isEmpty) {
      return DashboardGlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 18,
        child: Text('No new-member data yet.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
      );
    }

    final totalNewMembers = _growthTrend.fold<int>(0, (sum, p) => sum + p.newMembers);
    final maxVal = _growthTrend.map((e) => e.newMembers).reduce((a, b) => a > b ? a : b).toDouble();
    final safeMax = maxVal <= 0 ? 1.0 : maxVal;

    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$totalNewMembers',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'new members (last 6 months)',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _MembershipChartPainter(
                data: _growthTrend.map((e) => e.newMembers.toDouble()).toList(),
                maxVal: safeMax,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _growthTrend
                .map((p) => Text(
                      p.month.length >= 7 ? p.month.substring(5) : p.month,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ))
                .toList(),
          ),
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
        children: [
          ..._weeklyAttendance.map((data) {
            final value = data['value'] as double;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      data['day'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressBar(
                      progress: value,
                      color: _attendanceColor(value),
                      height: 8,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${(value * 100).toInt()}%',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
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

  Color _attendanceColor(double value) {
    if (value >= 0.85) return AppColors.accentCyan;
    if (value >= 0.70) return AppColors.accentBlue;
    if (value >= 0.55) return AppColors.accentOrange;
    return AppColors.accentCoral;
  }

  // ── Progress monitoring — attendance/session-based engagement proxy, not
  // literal workout/diet progress (real numbers, see `dashboard/progress` doc). ──
  Widget _buildProgressOverview() {
    if (_liveDataLoading) {
      return const DashboardGlassCard(
        padding: EdgeInsets.all(20),
        borderRadius: 18,
        child: SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator(color: AppColors.accentBlue, strokeWidth: 2)),
        ),
      );
    }

    final overview = _progressOverview;
    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _progressStat('Active', '${overview.activeMembers}', AppColors.accentCyan),
              ),
              Expanded(
                child: _progressStat('Inactive', '${overview.inactiveMembers}', AppColors.accentCoral),
              ),
              Expanded(
                child: _progressStat(
                  '7d Rate',
                  overview.activeMemberRate7dPercent != null
                      ? '${overview.activeMemberRate7dPercent!.toStringAsFixed(0)}%'
                      : '—',
                  AppColors.accentBlue,
                ),
              ),
            ],
          ),
          if (overview.byTrainer.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(color: AppColors.glassBorder, height: 1),
            const SizedBox(height: 12),
            Text('By trainer',
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ...overview.byTrainer.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(t.trainerName,
                            style: AppTextStyles.bodyMedium.copyWith(fontSize: 13)),
                      ),
                      Text(
                        '${t.assignedActiveClients} clients · ${t.clientCheckInRate7dPercent?.toStringAsFixed(0) ?? '—'}% check-in',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11),
                      ),
                    ],
                  ),
                )),
          ],
          if (overview.definition != null) ...[
            const SizedBox(height: 8),
            Text(overview.definition!,
                style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled, fontSize: 10)),
          ],
        ],
      ),
    );
  }

  Widget _progressStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800, color: color, fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
      ],
    );
  }

  // ── Subscription usage — member breakdown by individual premium tier ──
  Widget _buildSubscriptionUsage() {
    if (_liveDataLoading) {
      return const DashboardGlassCard(
        padding: EdgeInsets.all(20),
        borderRadius: 18,
        child: SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator(color: AppColors.accentBlue, strokeWidth: 2)),
        ),
      );
    }

    final usage = _subscriptionUsage;
    final tiers = [
      {'label': 'Free', 'count': usage.free, 'color': AppColors.textTertiary},
      {'label': 'Trial (Full)', 'count': usage.trialFull, 'color': AppColors.accentOrange},
      {'label': 'Trial (Limited)', 'count': usage.trialLimited, 'color': AppColors.accentBlue},
      {'label': 'Premium', 'count': usage.premium, 'color': AppColors.accentCyan},
    ];
    final total = usage.totalMembers == 0 ? 1 : usage.totalMembers;

    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
      child: Column(
        children: tiers.map((tier) {
          final count = tier['count'] as int;
          final color = tier['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 100,
                  child: Text(tier['label'] as String,
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressBar(progress: count / total, color: color, height: 6),
                ),
                const SizedBox(width: 12),
                Text('$count', style: AppTextStyles.labelLarge.copyWith(fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

}

// ── Custom painter for membership growth line chart ──
class _MembershipChartPainter extends CustomPainter {
  final List<double> data;
  final double maxVal;

  _MembershipChartPainter({required this.data, required this.maxVal});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.accentPurple
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.accentPurple.withValues(alpha: 0.25),
          AppColors.accentPurple.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    final minVal = data.reduce((a, b) => a < b ? a : b) * 0.9;
    final range = maxVal - minVal;

    for (var i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1);
      final y = size.height - ((data[i] - minVal) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        // Smooth curve
        final prevX = (i - 1) * size.width / (data.length - 1);
        final prevY = size.height -
            ((data[i - 1] - minVal) / range) * size.height;
        final controlX1 = prevX + (x - prevX) * 0.4;
        final controlX2 = x - (x - prevX) * 0.4;
        path.cubicTo(controlX1, prevY, controlX2, y, x, y);
        fillPath.cubicTo(controlX1, prevY, controlX2, y, x, y);
      }

      // Dot at each data point
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()..color = AppColors.accentPurple,
      );
    }

    // Fill
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Stroke
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
