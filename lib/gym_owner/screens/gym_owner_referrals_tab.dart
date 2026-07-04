import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';

class GymOwnerReferralsTab extends StatefulWidget {
  const GymOwnerReferralsTab({super.key});

  @override
  State<GymOwnerReferralsTab> createState() => _GymOwnerReferralsTabState();
}

class _GymOwnerReferralsTabState extends State<GymOwnerReferralsTab> {
  final List<Map<String, dynamic>> _referralStats = [
    {
      'title': 'Total Referrals',
      'value': '64',
      'icon': Icons.share_rounded,
      'color': AppColors.accentBlue,
    },
    {
      'title': 'Converted',
      'value': '42',
      'icon': Icons.check_circle_rounded,
      'color': AppColors.accentCyan,
    },
    {
      'title': 'Pending',
      'value': '14',
      'icon': Icons.pending_rounded,
      'color': AppColors.accentOrange,
    },
    {
      'title': 'Revenue',
      'value': '₹1.2L',
      'icon': Icons.currency_rupee_rounded,
      'color': AppColors.accentPurple,
    },
  ];

  final List<Map<String, dynamic>> _referralCodes = [
    {
      'code': 'FITFORGE25',
      'discount': '25% Off',
      'uses': 18,
      'maxUses': 50,
      'status': 'Active',
      'created': '15 May 2026',
    },
    {
      'code': 'SUMMER2026',
      'discount': '30% Off',
      'uses': 12,
      'maxUses': 30,
      'status': 'Active',
      'created': '1 Jun 2026',
    },
    {
      'code': 'GETFIT10',
      'discount': '10% Off',
      'uses': 45,
      'maxUses': 45,
      'status': 'Expired',
      'created': '10 Jan 2026',
    },
    {
      'code': 'NEWJOIN50',
      'discount': '50% Off (1st month)',
      'uses': 8,
      'maxUses': 20,
      'status': 'Active',
      'created': '20 Jun 2026',
    },
  ];

  final List<Map<String, dynamic>> _recentReferrals = [
    {
      'referrer': 'Rahul Sharma',
      'initials': 'RS',
      'referred': 'Deepa Nair',
      'date': '28 Jun 2026',
      'status': 'Joined',
      'gradientColors': [AppColors.accentBlue, AppColors.accentCyan],
    },
    {
      'referrer': 'Sneha Gupta',
      'initials': 'SG',
      'referred': 'Mohit Kumar',
      'date': '25 Jun 2026',
      'status': 'Pending',
      'gradientColors': [AppColors.accentPurple, AppColors.accentCoral],
    },
    {
      'referrer': 'Arjun Reddy',
      'initials': 'AR',
      'referred': 'Kavya Joshi',
      'date': '22 Jun 2026',
      'status': 'Joined',
      'gradientColors': [AppColors.accentCyan, AppColors.accentBlue],
    },
    {
      'referrer': 'Priya Patel',
      'initials': 'PP',
      'referred': 'Sai Teja',
      'date': '20 Jun 2026',
      'status': 'Expired',
      'gradientColors': [AppColors.accentOrange, AppColors.accentCoral],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Referrals',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage codes & track referrals',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                // Generate code button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentBlue.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'New Code',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
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
              .slideY(begin: -0.05, end: 0, duration: 500.ms),
        ),

        // Stats cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _buildStatsRow(),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 100.ms)
              .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 100.ms),
        ),

        // Referral Codes section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: _buildSectionLabel('REFERRAL CODES'),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildReferralCodeCard(_referralCodes[index])
                      .animate()
                      .fadeIn(
                          duration: 400.ms,
                          delay: Duration(milliseconds: 200 + index * 60))
                      .slideY(
                          begin: 0.05,
                          end: 0,
                          duration: 400.ms,
                          delay: Duration(milliseconds: 200 + index * 60)),
                );
              },
              childCount: _referralCodes.length,
            ),
          ),
        ),

        // Recent Referrals section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: _buildSectionLabel('RECENT REFERRALS'),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildRecentReferralCard(_recentReferrals[index])
                      .animate()
                      .fadeIn(
                          duration: 400.ms,
                          delay: Duration(milliseconds: 400 + index * 60))
                      .slideY(
                          begin: 0.05,
                          end: 0,
                          duration: 400.ms,
                          delay: Duration(milliseconds: 400 + index * 60)),
                );
              },
              childCount: _recentReferrals.length,
            ),
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

  Widget _buildStatsRow() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.8,
      ),
      itemCount: _referralStats.length,
      itemBuilder: (context, index) {
        final stat = _referralStats[index];
        final color = stat['color'] as Color;
        return DashboardGlassCard(
          padding: const EdgeInsets.all(14),
          borderRadius: 16,
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: color.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Icon(stat['icon'] as IconData, color: color, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stat['value'] as String,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    stat['title'] as String,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReferralCodeCard(Map<String, dynamic> code) {
    final isActive = code['status'] == 'Active';
    final usagePercent = (code['uses'] as int) / (code['maxUses'] as int);

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Code
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.accentBlue.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.accentBlue.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  code['code'] as String,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              // Status
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isActive
                      ? AppColors.accentCyan.withValues(alpha: 0.12)
                      : AppColors.textTertiary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: isActive
                        ? AppColors.accentCyan.withValues(alpha: 0.3)
                        : AppColors.textTertiary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  code['status'] as String,
                  style: AppTextStyles.caption.copyWith(
                    color: isActive
                        ? AppColors.accentCyan
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Copy button
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.glassBg,
                    border: Border.all(color: AppColors.glassBorder, width: 1),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.copy_rounded,
                      color: AppColors.textSecondary,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                code['discount'] as String,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                '${code['uses']}/${code['maxUses']} uses',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Usage bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: AppColors.bgTertiary,
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: usagePercent.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReferralCard(Map<String, dynamic> referral) {
    final gradientColors = referral['gradientColors'] as List<Color>;
    final status = referral['status'] as String;

    Color statusColor;
    switch (status) {
      case 'Joined':
        statusColor = AppColors.accentCyan;
        break;
      case 'Pending':
        statusColor = AppColors.accentOrange;
        break;
      default:
        statusColor = AppColors.textTertiary;
    }

    return DashboardGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Row(
        children: [
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
                referral['initials'] as String,
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
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
                  '${referral['referrer']}',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Referred ${referral['referred']} • ${referral['date']}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
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
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
