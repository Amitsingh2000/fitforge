import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trainer_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/trainer_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';
import 'trainer_availability_screen.dart';
import 'trainer_certifications_screen.dart';
import 'trainer_edit_profile_screen.dart';
import 'trainer_notification_settings_screen.dart';

class TrainerProfileTab extends ConsumerStatefulWidget {
  const TrainerProfileTab({super.key});

  @override
  ConsumerState<TrainerProfileTab> createState() => _TrainerProfileTabState();
}

class _TrainerProfileTabState extends ConsumerState<TrainerProfileTab> {
  TrainerProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final profile = await ref.read(trainerServiceProvider).getMyProfile();
      if (mounted) setState(() { _profile = profile; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = friendlyApiError(e); });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log out?', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log Out', style: TextStyle(color: AppColors.accentCoral))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: LoadingView(message: 'Loading your profile…'));
    }
    if (_error != null) {
      return Center(child: ErrorRetryView(message: _error!, onRetry: _load));
    }

    final user = ref.watch(authProvider).user;
    final profile = _profile!;
    final displayName = user?.name.trim().isNotEmpty == true ? user!.name : 'Trainer';
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'T';

    final menuItems = <_MenuItem>[
      _MenuItem(Icons.edit_rounded, 'Edit Profile', () async {
        final changed = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TrainerEditProfileScreen(initial: profile)),
        );
        if (changed == true) _load();
      }),
      _MenuItem(Icons.verified_user_rounded, 'Certifications & Badges', () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TrainerCertificationsScreen()),
        ).then((_) => _load());
      }),
      _MenuItem(Icons.calendar_month_rounded, 'My Availability Settings', () async {
        final changed = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TrainerAvailabilityScreen(initial: profile)),
        );
        if (changed == true) _load();
      }),
      _MenuItem(Icons.notifications_active_rounded, 'Notification Settings', () async {
        final changed = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TrainerNotificationSettingsScreen(initial: profile)),
        );
        if (changed == true) _load();
      }),
      _MenuItem(Icons.security_rounded, 'Security & Privacy', () => _comingSoon('Security & privacy')),
      _MenuItem(Icons.help_outline_rounded, 'Help & Support', () => _comingSoon('Help & support')),
    ];

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.accentBlue,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Profile', style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 26)),
                  const SizedBox(height: 4),
                  Text('View certificates, customize availability, and manage your account.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ),
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
                            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.accentCyan, AppColors.accentBlue]),
                            image: profile.photoUrls.isNotEmpty
                                ? DecorationImage(image: NetworkImage(profile.photoUrls.first), fit: BoxFit.cover)
                                : null,
                          ),
                          child: profile.photoUrls.isEmpty
                              ? Center(child: Text(initials, style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)))
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(child: Text(displayName, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                  if (profile.isVerified) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified_rounded, color: AppColors.accentCyan, size: 16),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.specializations.isNotEmpty ? profile.specializations.join(', ') : 'No specializations added yet',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.memberSince != null ? 'Member since ${user!.memberSince}' : '',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProfileStat(profile.experienceYears != null ? '${profile.experienceYears} yrs' : '—', 'Experience'),
                        _buildProfileStat('${profile.certifications.where((c) => c.verificationStatus == 'VERIFIED').length}', 'Verified Certs'),
                        _buildVerificationStat(profile.verificationStatus),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text('PORTAL SETTINGS', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
                        onTap: item.onTap,
                        child: Row(
                          children: [
                            Icon(item.icon, color: AppColors.accentCyan, size: 20),
                            const SizedBox(width: 14),
                            Expanded(child: Text(item.title, style: AppTextStyles.labelLarge.copyWith(fontSize: 14))),
                            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 14),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  DashboardGlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    borderRadius: 14,
                    borderColor: AppColors.accentCoral.withValues(alpha: 0.3),
                    onTap: _logout,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: AppColors.accentCoral, size: 18),
                        const SizedBox(width: 8),
                        Text('Logout Account', style: AppTextStyles.labelLarge.copyWith(color: AppColors.accentCoral, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 130),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms),
          ),
        ],
      ),
    );
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming soon')),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
      ],
    );
  }

  Widget _buildVerificationStat(String status) {
    final (color, label) = switch (status) {
      'VERIFIED' => (AppColors.accentCyan, 'Verified'),
      'PENDING' => (AppColors.accentOrange, 'Pending'),
      'REJECTED' => (AppColors.accentCoral, 'Rejected'),
      _ => (AppColors.textTertiary, 'Unverified'),
    };
    return Column(
      children: [
        Text(label, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        const SizedBox(height: 4),
        Text('Status', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  _MenuItem(this.icon, this.title, this.onTap);
}
