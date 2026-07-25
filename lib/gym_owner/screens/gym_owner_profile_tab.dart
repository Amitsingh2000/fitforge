import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';
import 'checkin_poster_screen.dart';
import 'gym_settings_screen.dart';
import 'invite_management_screen.dart';
import 'membership_plans_screen.dart';

class GymOwnerProfileTab extends ConsumerStatefulWidget {
  const GymOwnerProfileTab({super.key});

  @override
  ConsumerState<GymOwnerProfileTab> createState() => _GymOwnerProfileTabState();
}

class _GymOwnerProfileTabState extends ConsumerState<GymOwnerProfileTab> {
  Map<String, dynamic>? _gym;
  Map<String, dynamic>? _subscription;
  int _memberCount = 0;
  int _trainerCount = 0;
  bool _loading = true;
  String? _error;
  bool _startingTrial = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(gymOwnerServiceProvider);
      final results = await Future.wait([
        service.getGym(gymId),
        service.getGymSubscription(gymId),
        service.getMembers(gymId, role: 'MEMBER'),
        service.getMembers(gymId, role: 'TRAINER'),
      ]);
      if (mounted) {
        setState(() {
          _gym = results[0] as Map<String, dynamic>;
          _subscription = results[1] as Map<String, dynamic>?;
          _memberCount = (results[2] as List).length;
          _trainerCount = (results[3] as List).length;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = friendlyApiError(e); });
    }
  }

  Future<void> _startTrial() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    setState(() => _startingTrial = true);
    try {
      await ref.read(gymOwnerServiceProvider).startGymTrial(gymId);
      await _load();
    } catch (e) {
      if (mounted) {
        setState(() => _startingTrial = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start trial: ${friendlyApiError(e)}')),
        );
      }
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
    final user = ref.watch(authProvider).user;
    final gymName = ref.watch(selectedGymProvider)?.gymName ?? _gym?['name'] as String? ?? 'Your Gym';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text('Profile', style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800)),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.05, end: 0, duration: 500.ms),
        ),
        if (_loading)
          const SliverFillRemaining(hasScrollBody: false, child: Padding(padding: EdgeInsets.only(top: 80), child: LoadingView()))
        else if (_error != null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(padding: const EdgeInsets.only(top: 40), child: ErrorRetryView(message: _error!, onRetry: _load)),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProfileCard(user, gymName)
                    .animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 100.ms),
                const SizedBox(height: 20),
                _buildSectionLabel('SUBSCRIPTION'),
                const SizedBox(height: 12),
                _buildSubscriptionCard()
                    .animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 200.ms),
                const SizedBox(height: 20),
                _buildSectionLabel('GYM DETAILS'),
                const SizedBox(height: 12),
                _buildGymInfoCard()
                    .animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 300.ms),
                const SizedBox(height: 20),
                _buildSectionLabel('MANAGE'),
                const SizedBox(height: 12),
                _buildManageList()
                    .animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 400.ms),
                const SizedBox(height: 24),
                _buildLogoutButton()
                    .animate().fadeIn(duration: 500.ms, delay: 500.ms).slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 500.ms),
              ]),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(width: 3, height: 16, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: AppColors.primaryGradient)),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w700, letterSpacing: 1.2, fontSize: 11)),
      ],
    );
  }

  Widget _buildProfileCard(dynamic user, String gymName) {
    final firstName = user?.firstName as String? ?? '';
    final lastName = user?.lastName as String? ?? '';
    final email = user?.email as String? ?? '';
    final initials = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'G';

    return DashboardGlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 20,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.accentBlue, AppColors.accentPurple]),
              boxShadow: [BoxShadow(color: AppColors.accentBlue.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Center(
              child: Text(initials, style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28)),
            ),
          ),
          const SizedBox(height: 16),
          Text('$firstName $lastName'.trim().isEmpty ? 'Gym Owner' : '$firstName $lastName'.trim(),
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 22)),
          const SizedBox(height: 4),
          Text('Owner — $gymName', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary, fontSize: 14)),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(email, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentBlue, fontSize: 13)),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProfileStat('$_memberCount', 'Members'),
              _buildDivider(),
              _buildProfileStat('$_trainerCount', 'Trainers'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
      ],
    );
  }

  Widget _buildDivider() => Container(width: 1, height: 32, color: AppColors.glassBorder);

  Widget _buildSubscriptionCard() {
    if (_subscription == null) {
      return DashboardGlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No active subscription', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Start your free trial to unlock the full owner toolkit.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startingTrial ? null : _startTrial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _startingTrial
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Start Free Trial', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      );
    }

    final planCode = _subscription!['planCode'] as String? ?? 'GYM_PRO';
    final status = _subscription!['status'] as String? ?? 'TRIALING';
    final trialEndsAtStr = _subscription!['trialEndsAt'] as String?;
    final trialEndsAt = trialEndsAtStr != null ? DateTime.tryParse(trialEndsAtStr) : null;
    final isTrialing = status == 'TRIALING';

    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: AppColors.primaryGradient),
                child: Text(planCode.replaceAll('_', ' '),
                    style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.8)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.accentCyan.withValues(alpha: 0.12),
                  border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.3), width: 1),
                ),
                child: Text(status, style: AppTextStyles.caption.copyWith(color: AppColors.accentCyan, fontWeight: FontWeight.w600, fontSize: 10)),
              ),
            ],
          ),
          if (isTrialing && trialEndsAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: AppColors.textTertiary, size: 14),
                const SizedBox(width: 6),
                Text('Trial ends ${_fmt(trialEndsAt)}', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Widget _buildGymInfoCard() {
    final g = _gym ?? {};
    final addressParts = [g['addressLine'], g['city'], g['state'], g['pincode']]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join(', ');

    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
      child: Column(
        children: [
          _buildInfoRow(Icons.location_on_rounded, 'Location', addressParts.isNotEmpty ? addressParts : 'Not set'),
          _buildInfoRow(Icons.phone_rounded, 'Contact', g['phone'] as String? ?? 'Not set'),
          _buildInfoRow(Icons.email_outlined, 'Email', g['email'] as String? ?? 'Not set'),
          _buildInfoRow(Icons.account_balance_wallet_outlined, 'UPI ID', g['upiId'] as String? ?? 'Not set'),
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.accentBlue.withValues(alpha: 0.1)),
            child: Center(child: Icon(icon, color: AppColors.accentBlue, size: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10)),
                const SizedBox(height: 2),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageList() {
    final items = [
      {
        'icon': Icons.edit_outlined,
        'title': 'Gym Settings',
        'subtitle': 'Profile, address, UPI payout details',
        'color': AppColors.accentBlue,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GymSettingsScreen())).then((_) => _load()),
      },
      {
        'icon': Icons.qr_code_rounded,
        'title': 'Invite Codes',
        'subtitle': 'Let members, trainers & staff join',
        'color': AppColors.accentPurple,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InviteManagementScreen())),
      },
      {
        'icon': Icons.card_membership_outlined,
        'title': 'Membership Plans',
        'subtitle': 'Pricing tiers members can enroll in',
        'color': AppColors.accentCyan,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MembershipPlansScreen())),
      },
      {
        'icon': Icons.qr_code_2_rounded,
        'title': 'Check-in Poster',
        'subtitle': 'Front-desk self check-in QR',
        'color': AppColors.accentOrange,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckinPosterScreen())),
      },
    ];

    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      borderRadius: 18,
      child: Column(
        children: items.map((item) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: item['onTap'] as VoidCallback,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: (item['color'] as Color).withValues(alpha: 0.1)),
                      child: Center(child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 18)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title'] as String,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                          Text(item['subtitle'] as String, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
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
      onTap: _logout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.accentCoral.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.accentCoral, size: 18),
            const SizedBox(width: 8),
            Text('Log Out', style: AppTextStyles.labelLarge.copyWith(color: AppColors.accentCoral, fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
