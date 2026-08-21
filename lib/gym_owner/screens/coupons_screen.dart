import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/coupon.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';

/// Coupons & Offers screen.
/// Covers: `GET/POST/PATCH/DELETE /gyms/:gymId/coupons` and redemption history.
class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key, required this.gymId});

  final String gymId;

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends ConsumerState<CouponsScreen> {
  List<GymCoupon> _coupons = [];
  bool _loading = true;
  String? _error;
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await ref.read(gymOwnerServiceProvider).getCoupons(
        widget.gymId,
        includeInactive: _showInactive,
      );
      if (mounted) setState(() { _coupons = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = friendlyApiError(e); });
    }
  }

  Future<void> _openCreateSheet() async {
    final codeCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final limitCtrl = TextEditingController();
    String type = 'PERCENT';
    try {

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create Coupon', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  _inputField(codeCtrl, 'Coupon Code', hint: 'e.g. SAVE20'),
                  const SizedBox(height: 12),
                  Text('Type', style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['PERCENT', 'FLAT'].map((t) {
                      final selected = type == t;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setS(() => type = t),
                          child: Container(
                            margin: EdgeInsets.only(right: t == 'PERCENT' ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.accentBlue.withValues(alpha: 0.15) : AppColors.bgTertiary,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: selected ? AppColors.accentBlue : Colors.transparent),
                            ),
                            child: Text(
                              t == 'PERCENT' ? '% Percent' : '₹ Flat',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: selected ? AppColors.accentBlue : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  _inputField(valueCtrl, type == 'PERCENT' ? 'Discount (%)' : 'Discount (₹)',
                      hint: type == 'PERCENT' ? 'e.g. 20' : 'e.g. 500', keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _inputField(limitCtrl, 'Usage Limit (optional)', hint: 'Leave blank = unlimited', keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Create Coupon', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (saved == true && mounted) {
      final value = double.tryParse(valueCtrl.text);
      if (codeCtrl.text.trim().isEmpty || value == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a code and value')));
        return;
      }
      try {
        await ref.read(gymOwnerServiceProvider).createCoupon(
          widget.gymId,
          code: codeCtrl.text.trim().toUpperCase(),
          type: type,
          value: value,
          usageLimit: int.tryParse(limitCtrl.text),
        );
        if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coupon created ✓'))); _load(); }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
    } finally {
      codeCtrl.dispose();
      valueCtrl.dispose();
      limitCtrl.dispose();
    }
  }

  Future<void> _deactivate(GymCoupon c) async {
    try {
      await ref.read(gymOwnerServiceProvider).deactivateCoupon(widget.gymId, c.id);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coupon deactivated'))); _load(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _share(GymCoupon c) async {
    try {
      await ref.read(gymOwnerServiceProvider).shareCoupon(widget.gymId, c.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${c.code} shared with active members')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _showRedemptions(GymCoupon c) async {
    List<Map<String, dynamic>> redemptions = [];
    try {
      redemptions = await ref.read(gymOwnerServiceProvider).getCouponRedemptions(widget.gymId, c.id);
    } catch (_) {}
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.6),
        decoration: const BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${c.code} — Redemptions', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${c.usageCount} uses${c.usageLimit != null ? ' / ${c.usageLimit} limit' : ''}',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Expanded(
              child: redemptions.isEmpty
                  ? const Center(child: Text('No redemptions yet.', style: TextStyle(color: AppColors.textTertiary)))
                  : ListView.builder(
                      itemCount: redemptions.length,
                      itemBuilder: (ctx, i) {
                        final r = redemptions[i];
                        return ListTile(
                          leading: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                          title: Text(r['memberName'] as String? ?? 'Unknown',
                              style: const TextStyle(color: AppColors.textPrimary)),
                          subtitle: Text(r['redeemedAt'] as String? ?? '',
                              style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                          trailing: Text('−${c.displayValue}',
                              style: const TextStyle(color: AppColors.accentCyan, fontWeight: FontWeight.w600)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Coupons & Offers', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          Row(
            children: [
              Text('Show inactive', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              Switch(
                value: _showInactive,
                onChanged: (v) { setState(() => _showInactive = v); _load(); },
                activeColor: AppColors.accentBlue,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateSheet,
        backgroundColor: AppColors.accentBlue,
        icon: const Icon(Icons.local_offer_rounded),
        label: const Text('New Coupon', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue))
          : _error != null && _coupons.isEmpty
              ? Center(child: ErrorRetryView(message: _error!, onRetry: _load))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.accentBlue,
                  child: _coupons.isEmpty
                      ? ListView(children: const [SizedBox(height: 120), Center(child: EmptyStateView(icon: Icons.inbox_rounded, title: 'No coupons yet.\nTap + to create your first offer.'))])
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                          itemCount: _coupons.length,
                          itemBuilder: (ctx, i) => _CouponTile(
                            coupon: _coupons[i],
                            onShare: _coupons[i].isActive ? () => _share(_coupons[i]) : null,
                            onDeactivate: _coupons[i].isActive ? () => _deactivate(_coupons[i]) : null,
                            onViewRedemptions: () => _showRedemptions(_coupons[i]),
                          ),
                        ),
                ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, {String? hint, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.textPrimary),
          inputFormatters: keyboardType == TextInputType.text && label.contains('Code')
              ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_\-]'))]
              : [],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.bgTertiary,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _CouponTile extends StatelessWidget {
  const _CouponTile({
    required this.coupon,
    this.onShare,
    this.onDeactivate,
    required this.onViewRedemptions,
  });
  final GymCoupon coupon;
  final VoidCallback? onShare;
  final VoidCallback? onDeactivate;
  final VoidCallback onViewRedemptions;

  @override
  Widget build(BuildContext context) {
    final c = coupon;
    final active = c.isActive && !c.isExpired;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DashboardGlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: active ? AppColors.accentBlue.withValues(alpha: 0.1) : AppColors.textTertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(c.type == 'PERCENT' ? '%' : '₹',
                    style: AppTextStyles.titleLarge.copyWith(
                        color: active ? AppColors.accentBlue : AppColors.textTertiary,
                        fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.code, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700,
                      color: active ? AppColors.textPrimary : AppColors.textTertiary)),
                  Text('${c.displayValue}  ·  ${c.usageCount} uses${c.usageLimit != null ? '/${c.usageLimit}' : ''}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: onViewRedemptions,
                  child: Text('History', style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue)),
                ),
                if (onShare != null)
                  GestureDetector(
                    onTap: onShare,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('Share', style: AppTextStyles.caption.copyWith(color: AppColors.accentCyan)),
                    ),
                  ),
                if (onDeactivate != null)
                  GestureDetector(
                    onTap: onDeactivate,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('Deactivate', style: AppTextStyles.caption.copyWith(color: AppColors.accentCoral)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
