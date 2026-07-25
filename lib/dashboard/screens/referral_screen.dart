import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/referral_code.dart';
import '../../providers/gym_provider.dart';
import '../../services/member_service.dart';
import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';

/// Referral screen allowing members to view their shareable referral code,
/// redeem a friend's referral code, and see their past referrals.
class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  final _redeemCodeController = TextEditingController();

  ReferralCode? _referralCode;
  List<Referral> _myReferrals = [];
  bool _loading = true;
  bool _redeeming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  @override
  void dispose() {
    _redeemCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadReferralData() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null || gymId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'No active gym selected.';
      });
      return;
    }

    setState(() => _loading = true);

    try {
      final service = ref.read(memberServiceProvider);
      final codeObj = await service.getMyReferralCode(gymId);
      final list = await service.getMyReferrals(gymId);

      if (mounted) {
        setState(() {
          _referralCode = codeObj;
          _myReferrals = list;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _handleRedeem() async {
    final gymId = ref.read(currentGymIdProvider);
    final code = _redeemCodeController.text.trim();
    if (gymId == null || code.isEmpty) return;

    setState(() => _redeeming = true);

    try {
      final service = ref.read(memberServiceProvider);
      await service.redeemReferral(gymId: gymId, code: code);
      if (mounted) {
        setState(() => _redeeming = false);
        _redeemCodeController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Referral code redeemed successfully!'),
            backgroundColor: AppColors.accentBlue,
          ),
        );
        _loadReferralData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _redeeming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to redeem code: $e'),
            backgroundColor: AppColors.accentCoral,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedGym = ref.watch(selectedGymProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Referrals & Rewards', style: TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedGym != null) ...[
                      Text(
                        selectedGym.gymName ?? 'Active Gym',
                        style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                    ],

                    Text(
                      'Invite Friends & Earn Rewards',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Share your code with friends. Earn bonus days when they join!',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),

                    // My Code Card
                    if (_referralCode != null)
                      DashboardGlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'YOUR REFERRAL CODE',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10, letterSpacing: 1.2),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _referralCode!.code,
                                  style: AppTextStyles.titleLarge.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 28,
                                    letterSpacing: 3.0,
                                    color: AppColors.accentBlue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded, color: AppColors.textPrimary),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: _referralCode!.code));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Referral code copied to clipboard')),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStat('Total Invites', '${_referralCode!.totalReferrals}'),
                                Container(width: 1, height: 30, color: AppColors.glassBorder),
                                _buildStat('Qualified', '${_referralCode!.qualifiedReferrals}'),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 28),

                    // Redeem code input
                    Text(
                      'Redeem a Friend\'s Code',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _redeemCodeController,
                            textCapitalization: TextCapitalization.characters,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Enter code',
                              hintStyle: const TextStyle(color: AppColors.textTertiary),
                              filled: true,
                              fillColor: AppColors.bgSecondary,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.glassBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.accentBlue),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _redeeming ? null : _handleRedeem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _redeeming
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Redeem', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: AppColors.accentCoral, fontSize: 12),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // My Referrals List
                    Text(
                      'My Referrals (${_myReferrals.length})',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    if (_myReferrals.isEmpty)
                      DashboardGlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'No referrals yet. Share your code to get started!',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ..._myReferrals.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: DashboardGlassCard(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.refereeName,
                                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Status: ${r.status}',
                                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (r.status == 'QUALIFIED'
                                              ? const Color(0xFF16A34A)
                                              : AppColors.accentBlue)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      r.status,
                                      style: TextStyle(
                                        color: r.status == 'QUALIFIED'
                                            ? const Color(0xFF4ADE80)
                                            : AppColors.accentBlue,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }
}
