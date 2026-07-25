import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_session.dart';
import '../../services/member_service.dart';
import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Toggle values for preview preferences
  bool _notificationsEnabled = true;
  bool _remindersEnabled = true;
  String _units = 'Metric (kg, cm)';

  // Session management state
  List<UserSession> _sessions = [];
  bool _sessionsLoading = true;
  String? _sessionsError;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _sessionsLoading = true;
      _sessionsError = null;
    });
    try {
      final service = ref.read(memberServiceProvider);
      final sessions = await service.getSessions();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _sessionsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sessionsError = e.toString();
          _sessionsLoading = false;
        });
      }
    }
  }

  Future<void> _revokeSession(String sessionId) async {
    try {
      final service = ref.read(memberServiceProvider);
      await service.deleteSession(sessionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session revoked')),
        );
        _loadSessions(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to revoke session: $e')),
        );
      }
    }
  }

  Future<void> _logoutAllDevices() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text('Log out all devices?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will revoke all active sessions across every device. You will need to log in again.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Log out all',
                style: TextStyle(color: AppColors.accentCoral)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final service = ref.read(memberServiceProvider);
      await service.logoutAllDevices();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All devices logged out')),
        );
        _loadSessions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

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

                  // Active Sessions
                  _buildSectionLabel('ACTIVE SESSIONS'),
                  const SizedBox(height: 12),
                  _buildSessionsSection()
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 150.ms),
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
  // ACTIVE SESSIONS SECTION
  // ─────────────────────────────────────────────

  Widget _buildSessionsSection() {
    if (_sessionsLoading) {
      return DashboardGlassCard(
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accentBlue,
            ),
          ),
        ),
      );
    }

    if (_sessionsError != null) {
      return DashboardGlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.accentCoral, size: 28),
            const SizedBox(height: 8),
            Text(
              'Failed to load sessions',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _loadSessions,
              child: Text(
                'Retry',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_sessions.isEmpty) {
      return DashboardGlassCard(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No active sessions',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: [
        ..._sessions.map((session) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DashboardGlassCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: session.isCurrent
                            ? AppColors.accentBlue.withValues(alpha: 0.12)
                            : AppColors.bgTertiary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _deviceIcon(session.deviceName),
                        color: session.isCurrent
                            ? AppColors.accentBlue
                            : AppColors.textTertiary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  session.deviceName,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (session.isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentCyan
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'This device',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.accentCyan,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Last active: ${session.lastUsedLabel}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!session.isCurrent)
                      GestureDetector(
                        onTap: () => _revokeSession(session.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                AppColors.accentCoral.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.accentCoral
                                    .withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            'Revoke',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accentCoral,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _logoutAllDevices,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.accentCoral.withValues(alpha: 0.15)),
            ),
            child: Center(
              child: Text(
                'Log out all devices',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentCoral,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _deviceIcon(String deviceName) {
    if (deviceName.contains('Android')) return Icons.phone_android_rounded;
    if (deviceName.contains('iPhone') || deviceName.contains('iOS')) {
      return Icons.phone_iphone_rounded;
    }
    if (deviceName.contains('Windows')) return Icons.desktop_windows_rounded;
    if (deviceName.contains('Mac')) return Icons.laptop_mac_rounded;
    if (deviceName.contains('Linux')) return Icons.computer_rounded;
    return Icons.devices_rounded;
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
