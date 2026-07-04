import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';

class TrainerProfileTab extends StatelessWidget {
  const TrainerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.edit_rounded, 'title': 'Edit Profile'},
      {'icon': Icons.verified_user_rounded, 'title': 'Certifications & Badges'},
      {'icon': Icons.calendar_month_rounded, 'title': 'My Availability Settings'},
      {'icon': Icons.notifications_active_rounded, 'title': 'Notification Settings'},
      {'icon': Icons.security_rounded, 'title': 'Security & Privacy'},
      {'icon': Icons.help_outline_rounded, 'title': 'Help & Support'},
    ];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Profile',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View certificates, customize availability, and manage your account.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Profile brief card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: DashboardGlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.accentCyan, AppColors.accentBlue],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'CA',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Coach Anil Kumar',
                              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Elite Strength Coach',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Member since Jan 2025',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: AppColors.glassBorder),
                  const SizedBox(height: 16),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileStat('6 Years', 'Experience'),
                      _buildProfileStat('98%', 'Success Rate'),
                      _buildProfileStat('150+', 'Active Members'),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(),
        ),

        // Menu items
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'PORTAL SETTINGS',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: menuItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return DashboardGlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      borderRadius: 14,
                      child: Row(
                        children: [
                          Icon(item['icon'] as IconData, color: AppColors.accentCyan, size: 20),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item['title'] as String,
                              style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 14),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Logout button
                DashboardGlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  borderRadius: 14,
                  borderColor: AppColors.accentCoral.withValues(alpha: 0.3),
                  onTap: () {
                    // Sign out and navigate back to trainer login
                    Navigator.of(context).pushReplacementNamed('/trainer-login');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded, color: AppColors.accentCoral, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Logout Account',
                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.accentCoral, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 130), // space for bottom nav
              ],
            ),
          ).animate().fadeIn(delay: 150.ms),
        ),
      ],
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11),
        ),
      ],
    );
  }
}
