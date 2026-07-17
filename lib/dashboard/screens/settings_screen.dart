import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Toggle values for preview preferences
  bool _notificationsEnabled = true;
  bool _remindersEnabled = true;
  String _units = 'Metric (kg, cm)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar Header
            SliverToBoxAdapter(child: _buildHeader()),

            // Content body
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 12),

                  // App Settings Preference list
                  _buildSectionLabel('PREFERENCES'),
                  const SizedBox(height: 12),
                  _buildPreferencesList()
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 100.ms),
                  const SizedBox(height: 20),

                  // Support & Help
                  _buildSectionLabel('SUPPORT'),
                  const SizedBox(height: 12),
                  _buildSupportSection()
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
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
            onTap: () => Navigator.of(context).pop(),
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
          Text(
            'Settings',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // APP PREFERENCES LIST
  // ─────────────────────────────────────────────

  Widget _buildPreferencesList() {
    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildSwitchListTile(
            title: 'Push Notifications',
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          Divider(color: AppColors.glassBorder, height: 1),
          _buildSwitchListTile(
            title: 'Daily Reminders',
            value: _remindersEnabled,
            onChanged: (val) => setState(() => _remindersEnabled = val),
          ),
          Divider(color: AppColors.glassBorder, height: 1),
          _buildSimpleActionTile(
            title: 'Units & Measurements',
            subtitle: _units,
            onTap: () {
              setState(() {
                _units = _units.startsWith('Metric') ? 'Imperial (lbs, in)' : 'Metric (kg, cm)';
              });
            },
          ),
          Divider(color: AppColors.glassBorder, height: 1),
          _buildSimpleActionTile(
            title: 'App Language',
            subtitle: 'English (US)',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchListTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accentBlue,
            activeTrackColor: AppColors.accentBlue.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleActionTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SUPPORT SECTION
  // ─────────────────────────────────────────────

  Widget _buildSupportSection() {
    final supportItems = [
      {'title': 'Help Center', 'icon': Icons.help_outline_rounded},
      {'title': 'Contact Support', 'icon': Icons.mail_outline_rounded},
      {'title': 'Report an Issue', 'icon': Icons.bug_report_outlined},
      {'title': 'Privacy Policy', 'icon': Icons.lock_outline_rounded},
    ];

    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: supportItems.map((item) {
          return GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(item['icon'] as IconData, color: AppColors.textTertiary, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        item['title'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Helper title label
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
