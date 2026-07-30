import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/brilliant_theme.dart';
import '../widgets/dashboard_glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _remindersEnabled = true;
  String _units = 'Metric (kg, cm)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrilliantColors.bgPrimary,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 12),

                  _buildSectionLabel('PREFERENCES'),
                  const SizedBox(height: 10),
                  _buildPreferencesList()
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: 20),

                  _buildSectionLabel('SUPPORT & LEGAL'),
                  const SizedBox(height: 10),
                  _buildSupportSection()
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
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
          const SizedBox(width: 14),
          Text(
            'Settings',
            style: BrilliantTheme.headerStyle(fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: BrilliantTheme.badgeStyle(color: BrilliantColors.mint));
  }

  Widget _buildPreferencesList() {
    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Column(
        children: [
          _buildSwitchListTile(
            title: 'Push Notifications',
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          Divider(color: BrilliantColors.surfaceBorder, height: 1),
          _buildSwitchListTile(
            title: 'Daily Reminders',
            value: _remindersEnabled,
            onChanged: (val) => setState(() => _remindersEnabled = val),
          ),
          Divider(color: BrilliantColors.surfaceBorder, height: 1),
          _buildSimpleActionTile(
            title: 'Units & Measurements',
            subtitle: _units,
            onTap: () {
              setState(() {
                _units = _units.startsWith('Metric') ? 'Imperial (lbs, in)' : 'Metric (kg, cm)';
              });
            },
          ),
          Divider(color: BrilliantColors.surfaceBorder, height: 1),
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
          Text(title, style: const TextStyle(color: BrilliantColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: BrilliantColors.mint,
            activeTrackColor: BrilliantColors.mint.withValues(alpha: 0.3),
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
                Text(title, style: const TextStyle(color: BrilliantColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: BrilliantColors.textMuted, fontSize: 11)),
              ],
            ),
            const Icon(Icons.chevron_right_rounded, color: BrilliantColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    final supportItems = [
      {'title': 'Help Center', 'icon': Icons.help_outline_rounded},
      {'title': 'Contact Support', 'icon': Icons.mail_outline_rounded},
      {'title': 'Report an Issue', 'icon': Icons.bug_report_outlined},
      {'title': 'Privacy Policy', 'icon': Icons.lock_outline_rounded},
    ];

    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
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
                      Icon(item['icon'] as IconData, color: BrilliantColors.mint, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        item['title'] as String,
                        style: const TextStyle(color: BrilliantColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right_rounded, color: BrilliantColors.textMuted, size: 20),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
