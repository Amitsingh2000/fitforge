import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';

class GymOwnerProfileTab extends StatelessWidget {
  const GymOwnerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(
              'Profile',
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: -0.05, end: 0, duration: 500.ms),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Profile card
              _buildProfileCard()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(
                      begin: 0.05, end: 0, duration: 500.ms, delay: 100.ms),
              const SizedBox(height: 20),

              // Subscription info
              _buildSectionLabel('SUBSCRIPTION'),
              const SizedBox(height: 12),
              _buildSubscriptionCard()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(
                      begin: 0.05, end: 0, duration: 500.ms, delay: 200.ms),
              const SizedBox(height: 20),

              // Gym info
              _buildSectionLabel('GYM DETAILS'),
              const SizedBox(height: 12),
              _buildGymInfoCard()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .slideY(
                      begin: 0.05, end: 0, duration: 500.ms, delay: 300.ms),
              const SizedBox(height: 20),

              // Settings
              _buildSectionLabel('SETTINGS'),
              const SizedBox(height: 12),
              _buildSettingsList()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms)
                  .slideY(
                      begin: 0.05, end: 0, duration: 500.ms, delay: 400.ms),
              const SizedBox(height: 24),

              // Logout button
              _buildLogoutButton()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms)
                  .slideY(
                      begin: 0.05, end: 0, duration: 500.ms, delay: 500.ms),
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

  Widget _buildProfileCard() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 20,
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accentBlue, AppColors.accentPurple],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentBlue.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'AK',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            'Amit Kumar',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Owner — FitForge Elite Gym',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'amit@fitforgeelite.com',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.accentBlue,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          // Quick stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProfileStat('248', 'Members'),
              _buildDivider(),
              _buildProfileStat('12', 'Trainers'),
              _buildDivider(),
              _buildProfileStat('2.5 yrs', 'Active'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.glassBorder,
    );
  }

  Widget _buildSubscriptionCard() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: AppColors.primaryGradient,
                ),
                child: Text(
                  'PRO PLAN',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '₹2,499/mo',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Features
          _buildFeatureRow(Icons.check_circle_rounded, 'Unlimited members'),
          _buildFeatureRow(Icons.check_circle_rounded, 'Advanced analytics'),
          _buildFeatureRow(Icons.check_circle_rounded, 'Referral system'),
          _buildFeatureRow(Icons.check_circle_rounded, 'Priority support'),

          const SizedBox(height: 16),

          // Renewal info
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: AppColors.textTertiary,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Renews on 15 Aug 2026',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.accentCyan.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.accentCyan.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Active',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentCyan,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentCyan, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGymInfoCard() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
      child: Column(
        children: [
          _buildInfoRow(Icons.location_on_rounded, 'Location',
              'MG Road, Bangalore 560001'),
          _buildInfoRow(
              Icons.access_time_rounded, 'Hours', '5:00 AM — 11:00 PM'),
          _buildInfoRow(Icons.phone_rounded, 'Contact', '+91 98765 43210'),
          _buildInfoRow(
              Icons.language_rounded, 'Website', 'fitforgeelite.com'),
          _buildInfoRow(Icons.square_foot_rounded, 'Area', '5,200 sq. ft.'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.accentBlue.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Icon(icon, color: AppColors.accentBlue, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    final settings = [
      {
        'icon': Icons.notifications_rounded,
        'title': 'Notifications',
        'color': AppColors.accentOrange
      },
      {
        'icon': Icons.security_rounded,
        'title': 'Privacy & Security',
        'color': AppColors.accentPurple
      },
      {
        'icon': Icons.palette_rounded,
        'title': 'Appearance',
        'color': AppColors.accentCyan
      },
      {
        'icon': Icons.help_outline_rounded,
        'title': 'Help & Support',
        'color': AppColors.accentBlue
      },
      {
        'icon': Icons.info_outline_rounded,
        'title': 'About FitForge',
        'color': AppColors.textSecondary
      },
    ];

    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      borderRadius: 18,
      child: Column(
        children: settings.map((setting) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: (setting['color'] as Color)
                            .withValues(alpha: 0.1),
                      ),
                      child: Center(
                        child: Icon(
                          setting['icon'] as IconData,
                          color: setting['color'] as Color,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        setting['title'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.accentCoral.withValues(alpha: 0.1),
          border: Border.all(
            color: AppColors.accentCoral.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: AppColors.accentCoral,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Log Out',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.accentCoral,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
