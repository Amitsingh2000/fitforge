import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';

class GymOwnerReferralsTab extends ConsumerStatefulWidget {
  const GymOwnerReferralsTab({super.key});

  @override
  ConsumerState<GymOwnerReferralsTab> createState() =>
      _GymOwnerReferralsTabState();
}

class _GymOwnerReferralsTabState extends ConsumerState<GymOwnerReferralsTab> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  Map<String, dynamic>? _config;

  String _editRewardType = 'FREE_DAYS';
  double _editRewardValue = 7;
  String? _ownerCode;
  int _ownerReferralCount = 0;

  static const _rewardTypes = [
    {'value': 'FREE_DAYS', 'label': 'Free Days', 'icon': Icons.calendar_today_rounded},
    {'value': 'FLAT_DISCOUNT_COUPON', 'label': 'Flat Discount Coupon', 'icon': Icons.percent_rounded},
  ];

  static const _freeDaysOptions = [3, 5, 7, 14, 30];
  static const _discountOptions = [50, 100, 150, 200, 500];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null || gymId.isEmpty) {
      setState(() { _loading = false; _error = 'No active gym selected.'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final service = ref.read(gymOwnerServiceProvider);
      final config = await service.getReferralConfig(gymId);
      String? code;
      var count = 0;
      try {
        final owner = await service.getOrCreateOwnerReferralCode();
        code = owner['code'] as String?;
        count = (await service.getMyOwnerReferrals()).length;
      } catch (_) {}
      if (mounted) {
        setState(() {
          _config = config;
          _ownerCode = code;
          _ownerReferralCount = count;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _saveConfig() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(gymOwnerServiceProvider).setReferralConfig(
        gymId, rewardType: _editRewardType, rewardValue: _editRewardValue,
      );
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Referral reward config updated!', success: true);
        await _loadData();
      }
    } catch (e) {
      if (mounted) _showSnackBar('Failed to save: $e', success: false);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.accentBlue));
    if (_error != null) return _buildErrorState();

    return Stack(children: [
      CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Referrals', style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Configure & track member referrals', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
            ]),
            GestureDetector(onTap: _showConfigPopup, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: AppColors.primaryGradient,
                boxShadow: [BoxShadow(color: AppColors.accentBlue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.settings_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text('Configure', style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
              ]),
            )),
          ]),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.05, end: 0, duration: 500.ms)),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _buildConfigCard(),
        ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 100.ms)),

        if (_ownerCode != null)
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _buildOwnerCodeCard(),
          )),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: _buildHowItWorksCard(),
        ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 200.ms)),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: _buildInfoCard(),
        ).animate().fadeIn(duration: 500.ms, delay: 300.ms)),
      ]),

      Positioned(bottom: 90, right: 20, child: _buildFAB()
          .animate().scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 500.ms, delay: 500.ms, curve: Curves.elasticOut)),
    ]);
  }

  Widget _buildOwnerCodeCard() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.share_rounded, color: AppColors.accentPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Owner referral code', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                Text(_ownerCode ?? '', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
                Text('$_ownerReferralCount gyms signed up with this code',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _ownerCode ?? ''));
              _showSnackBar('Code copied', success: true);
            },
            icon: const Icon(Icons.copy_rounded, color: AppColors.accentCyan),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigCard() {
    final bool configured = _config != null;
    final String rewardType = _config?['rewardType'] as String? ?? '';
    final num rewardValue = _config?['rewardValue'] as num? ?? 0;
    final bool isActive = _config?['isActive'] as bool? ?? true;

    String rewardLabel; IconData rewardIcon; Color rewardColor;
    if (rewardType == 'FREE_DAYS') {
      rewardLabel = '${rewardValue.toInt()} Free Days';
      rewardIcon = Icons.calendar_today_rounded; rewardColor = AppColors.accentCyan;
    } else if (rewardType == 'FLAT_DISCOUNT_COUPON') {
      rewardLabel = '₹${rewardValue.toInt()} Discount Coupon';
      rewardIcon = Icons.percent_rounded; rewardColor = AppColors.accentPurple;
    } else {
      rewardLabel = 'Not configured'; rewardIcon = Icons.help_outline_rounded; rewardColor = AppColors.textTertiary;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: configured
            ? [AppColors.accentBlue.withValues(alpha: 0.12), AppColors.accentPurple.withValues(alpha: 0.06)]
            : [AppColors.bgSecondary, AppColors.bgTertiary]),
        border: Border.all(color: configured ? AppColors.accentBlue.withValues(alpha: 0.25) : AppColors.glassBorder, width: 1.5),
        boxShadow: configured ? [BoxShadow(color: AppColors.accentBlue.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))] : [],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(padding: const EdgeInsets.all(20),
            child: configured ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: rewardColor.withValues(alpha: 0.12)),
                  child: Center(child: Icon(rewardIcon, color: rewardColor, size: 22))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Current Reward', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10, letterSpacing: 0.8, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(rewardLabel, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800, color: rewardColor)),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
                    color: (isActive ? AppColors.accentCyan : AppColors.accentCoral).withValues(alpha: 0.1),
                    border: Border.all(color: (isActive ? AppColors.accentCyan : AppColors.accentCoral).withValues(alpha: 0.3))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? AppColors.accentCyan : AppColors.accentCoral)),
                    const SizedBox(width: 5),
                    Text(isActive ? 'Active' : 'Inactive', style: AppTextStyles.caption.copyWith(color: isActive ? AppColors.accentCyan : AppColors.accentCoral, fontWeight: FontWeight.w600, fontSize: 10)),
                  ])),
              ]),
              const SizedBox(height: 16),
              Row(children: List.generate(40, (_) => Expanded(child: Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 2), color: AppColors.glassBorder)))),
              const SizedBox(height: 14),
              Row(children: [
                _buildConfigChip(Icons.card_giftcard_rounded, rewardType == 'FREE_DAYS' ? 'Free Days' : 'Coupon', AppColors.accentBlue),
                const SizedBox(width: 8),
                _buildConfigChip(Icons.people_alt_rounded, 'Per Referral', AppColors.accentPurple),
                const SizedBox(width: 8),
                GestureDetector(onTap: _showConfigPopup, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), gradient: AppColors.primaryGradient),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.edit_rounded, color: Colors.white, size: 11),
                    const SizedBox(width: 4),
                    Text('Edit', style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10)),
                  ]),
                )),
              ]),
            ]) : _buildNotConfiguredState(),
          ),
        ),
      ),
    );
  }

  Widget _buildConfigChip(IconData icon, String label, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: color.withValues(alpha: 0.06), border: Border.all(color: color.withValues(alpha: 0.12))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 11), const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 9)),
      ]),
    ));
  }

  Widget _buildNotConfiguredState() {
    return Column(children: [
      Icon(Icons.card_giftcard_outlined, color: AppColors.textDisabled, size: 40),
      const SizedBox(height: 12),
      Text('Referral Reward Not Configured', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Text('Set up a reward for members who refer new friends to your gym.', textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
      const SizedBox(height: 16),
      GestureDetector(onTap: _showConfigPopup, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: AppColors.primaryGradient),
        child: Text('Set Up Reward', style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
      )),
    ]);
  }

  Widget _buildHowItWorksCard() {
    final steps = [
      {'title': 'Member shares code', 'desc': 'Each member has a unique referral code visible in their app.', 'color': AppColors.accentBlue, 'icon': Icons.share_rounded},
      {'title': 'Friend joins gym', 'desc': 'The referred friend signs up using the referral code.', 'color': AppColors.accentCyan, 'icon': Icons.person_add_rounded},
      {'title': 'Reward unlocked', 'desc': 'The referrer earns the configured reward automatically.', 'color': AppColors.accentPurple, 'icon': Icons.card_giftcard_rounded},
    ];
    return DashboardGlassCard(padding: const EdgeInsets.all(18), borderRadius: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: AppColors.primaryGradient)),
        const SizedBox(width: 8),
        Text('HOW IT WORKS', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w700, letterSpacing: 1.2, fontSize: 10)),
      ]),
      const SizedBox(height: 16),
      ...steps.asMap().entries.map((e) {
        final step = e.value; final isLast = e.key == steps.length - 1; final color = step['color'] as Color;
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.12), border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5)),
              child: Center(child: Icon(step['icon'] as IconData, color: color, size: 14))),
            if (!isLast) Container(width: 1.5, height: 32, margin: const EdgeInsets.symmetric(vertical: 4), color: AppColors.glassBorder),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Padding(padding: EdgeInsets.only(bottom: isLast ? 0 : 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 6),
            Text(step['title'] as String, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 2),
            Text(step['desc'] as String, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
          ]))),
        ]);
      }),
    ]));
  }

  Widget _buildInfoCard() {
    return DashboardGlassCard(padding: const EdgeInsets.all(18), borderRadius: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: AppColors.primaryGradient)),
        const SizedBox(width: 8),
        Text('REWARD TYPES', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w700, letterSpacing: 1.2, fontSize: 10)),
      ]),
      const SizedBox(height: 14),
      _buildRewardTypeInfo(
        icon: Icons.calendar_today_rounded,
        color: AppColors.accentCyan,
        title: 'Free Days',
        desc: "Extends the referrer's active membership by the configured number of days when their friend joins and completes enrollment.",
      ),
      const SizedBox(height: 12),
      _buildRewardTypeInfo(
        icon: Icons.percent_rounded,
        color: AppColors.accentPurple,
        title: 'Flat Discount Coupon',
        desc: "Generates a coupon code for the referrer that can be applied on their next membership renewal for the configured INR amount.",
      ),
    ]));
  }

  Widget _buildRewardTypeInfo({required IconData icon, required Color color, required String title, required String desc}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: color.withValues(alpha: 0.1)), child: Center(child: Icon(icon, color: color, size: 16))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 3),
        Text(desc, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
      ])),
    ]);
  }

  Widget _buildErrorState() {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: DashboardGlassCard(padding: const EdgeInsets.all(28), borderRadius: 20, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.cloud_off_rounded, color: AppColors.accentCoral, size: 44),
      const SizedBox(height: 16),
      Text('Failed to load referral config', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text(_error ?? 'Unknown error', textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
      const SizedBox(height: 20),
      GestureDetector(onTap: _loadData, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: AppColors.primaryGradient),
        child: Text('Retry', style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
      )),
    ]))));
  }

  void _showConfigPopup() {
    _editRewardType = _config?['rewardType'] as String? ?? 'FREE_DAYS';
    _editRewardValue = (_config?['rewardValue'] as num?)?.toDouble() ?? 7;

    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (context, setSheetState) {
        final isFree = _editRewardType == 'FREE_DAYS';
        final options = isFree ? _freeDaysOptions : _discountOptions;
        final unit = isFree ? '' : '₹'; final suffix = isFree ? ' Days' : '';
        if (!options.map((o) => o.toDouble()).contains(_editRewardValue)) _editRewardValue = options.first.toDouble();

        return Container(
          decoration: BoxDecoration(color: AppColors.bgSecondary, borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, -10))]),
          padding: EdgeInsets.fromLTRB(24, 12, 24, 36 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: AppColors.textDisabled)),
            const SizedBox(height: 20),
            Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: AppColors.primaryGradient),
                child: const Center(child: Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 20))),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Referral Reward Config', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                Text('Reward given to referrer on qualified join', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
              ]),
            ]),
            const SizedBox(height: 24),

            _buildSheetSection(label: 'Reward Type', icon: Icons.card_giftcard_rounded, color: AppColors.accentBlue,
              child: Column(children: _rewardTypes.map((rt) {
                final isSelected = rt['value'] == _editRewardType;
                return GestureDetector(onTap: () => setSheetState(() {
                  _editRewardType = rt['value'] as String;
                  _editRewardValue = (_editRewardType == 'FREE_DAYS' ? _freeDaysOptions.first : _discountOptions.first).toDouble();
                }), child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                    color: isSelected ? AppColors.accentBlue.withValues(alpha: 0.12) : AppColors.glassBg,
                    border: Border.all(color: isSelected ? AppColors.accentBlue.withValues(alpha: 0.5) : AppColors.glassBorder, width: isSelected ? 1.5 : 1)),
                  child: Row(children: [
                    Icon(rt['icon'] as IconData, color: isSelected ? AppColors.accentBlue : AppColors.textTertiary, size: 18),
                    const SizedBox(width: 12),
                    Text(rt['label'] as String, style: AppTextStyles.labelLarge.copyWith(color: isSelected ? AppColors.accentBlue : AppColors.textSecondary, fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                    const Spacer(),
                    if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.accentBlue, size: 16),
                  ]),
                ));
              }).toList()),
            ),
            const SizedBox(height: 16),

            _buildSheetSection(label: isFree ? 'Free Days' : 'Discount Amount (₹)', icon: isFree ? Icons.calendar_today_rounded : Icons.currency_rupee_rounded, color: AppColors.accentCyan,
              child: Wrap(spacing: 8, runSpacing: 8, children: options.map((v) {
                final isSelected = v == _editRewardValue.toInt();
                return GestureDetector(onTap: () => setSheetState(() => _editRewardValue = v.toDouble()),
                  child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                      color: isSelected ? AppColors.accentCyan.withValues(alpha: 0.15) : AppColors.glassBg,
                      border: Border.all(color: isSelected ? AppColors.accentCyan.withValues(alpha: 0.5) : AppColors.glassBorder, width: isSelected ? 1.5 : 1)),
                    child: Text('$unit$v$suffix', style: AppTextStyles.labelLarge.copyWith(color: isSelected ? AppColors.accentCyan : AppColors.textSecondary, fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                  ),
                );
              }).toList()),
            ),
            const SizedBox(height: 28),

            GestureDetector(onTap: _saving ? null : _saveConfig, child: AnimatedContainer(duration: const Duration(milliseconds: 200),
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
                gradient: _saving ? null : const LinearGradient(colors: [AppColors.accentBlue, Color(0xFF6366F1)]),
                color: _saving ? AppColors.textDisabled.withValues(alpha: 0.3) : null,
                boxShadow: _saving ? [] : [BoxShadow(color: AppColors.accentBlue.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))]),
              child: Center(child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Save Reward Config', style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))),
            )),
          ]),
        );
      }),
    );
  }

  Widget _buildSheetSection({required String label, required IconData icon, required Color color, required Widget child}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: color, size: 14), const SizedBox(width: 6),
        Text(label, style: AppTextStyles.labelLarge.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ]),
      const SizedBox(height: 10),
      child,
    ]);
  }

  Widget _buildFAB() {
    return GestureDetector(onTap: _showConfigPopup, child: Container(
      width: 56, height: 56,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.accentCyan, AppColors.accentBlue]),
        boxShadow: [BoxShadow(color: AppColors.accentCyan.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6)), BoxShadow(color: AppColors.accentCyan.withValues(alpha: 0.15), blurRadius: 32, offset: const Offset(0, 12))]),
      child: const Center(child: Icon(Icons.settings_rounded, color: Colors.white, size: 26)),
    ));
  }

  void _showSnackBar(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontSize: 13)),
      backgroundColor: success ? AppColors.accentBlue : AppColors.accentCoral,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      duration: const Duration(seconds: 2),
    ));
  }
}
