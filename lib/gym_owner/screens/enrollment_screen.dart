import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/enrollment.dart';
import '../../models/gym_member.dart';
import '../../models/gym_membership.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';

/// Membership lifecycle screen — launched from [MemberDetailScreen].
/// Wraps: `GET/POST /gyms/:gymId/memberships`, freeze/unfreeze/renew/change-plan.
class EnrollmentScreen extends ConsumerStatefulWidget {
  const EnrollmentScreen({
    super.key,
    required this.gymId,
    required this.member,
  });

  final String gymId;
  final GymMember member;

  @override
  ConsumerState<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends ConsumerState<EnrollmentScreen> {
  List<Enrollment> _enrollments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(gymOwnerServiceProvider);
      final list = await service.getEnrollments(
        widget.gymId,
        memberId: widget.member.userId,
      );
      if (mounted) setState(() { _enrollments = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = friendlyApiError(e); });
    }
  }

  // ── Enroll bottom-sheet ─────────────────────────────────────────────────────
  Future<void> _openEnrollSheet() async {
    final service = ref.read(gymOwnerServiceProvider);
    List<Map<String, dynamic>> plans = [];
    try {
      plans = await service.getPlans(widget.gymId);
    } catch (_) {}

    if (!mounted || plans.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active plans found. Create a plan first.')),
        );
      }
      return;
    }

    String? selectedPlanId;
    final couponCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    try {

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
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
                  Text('Enroll Member', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Enroll ${widget.member.fullName} in a plan.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  Text('Select Plan', style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1)),
                  const SizedBox(height: 8),
                  ...plans.map((p) {
                    final pid = p['id'] as String? ?? '';
                    final isSelected = selectedPlanId == pid;
                    return GestureDetector(
                      onTap: () => setState(() => selectedPlanId = pid),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentBlue.withValues(alpha: 0.15)
                              : AppColors.bgTertiary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentBlue
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['name'] as String? ?? '',
                                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                  Text(
                                    '₹${p['priceInr']} · ${p['durationDays'] != null ? '${p['durationDays']} days' : '${p['sessionCount']} sessions'}',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded, color: AppColors.accentBlue, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  _inputField(couponCtrl, 'Coupon Code (optional)', hint: 'e.g. SAVE20'),
                  const SizedBox(height: 12),
                  _inputField(priceCtrl, 'Override Price (optional)', hint: 'Leave blank to use plan price', keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedPlanId == null ? null : () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Confirm Enrollment', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (saved == true && selectedPlanId != null && mounted) {
      try {
        await service.enrollMember(
          widget.gymId,
          userId: widget.member.userId,
          planId: selectedPlanId!,
          couponCode: couponCtrl.text.trim().isEmpty ? null : couponCtrl.text.trim(),
          priceOverride: double.tryParse(priceCtrl.text),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Member enrolled successfully ✓')),
          );
          _load();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enrollment failed: $e')));
        }
      }
    }
    } finally {
      couponCtrl.dispose();
      priceCtrl.dispose();
    }
  }

  // ── Actions on an existing enrollment ────────────────────────────────────────
  Future<void> _freeze(Enrollment e) async {
    try {
      await ref.read(gymOwnerServiceProvider).freezeEnrollment(widget.gymId, e.id);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enrollment frozen ✓'))); _load(); }
    } catch (err) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$err')));
    }
  }

  Future<void> _unfreeze(Enrollment e) async {
    try {
      await ref.read(gymOwnerServiceProvider).unfreezeEnrollment(widget.gymId, e.id);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enrollment unfrozen ✓'))); _load(); }
    } catch (err) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$err')));
    }
  }

  Future<void> _renew(Enrollment e) async {
    try {
      await ref.read(gymOwnerServiceProvider).renewEnrollment(widget.gymId, e.id);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enrollment renewed ✓'))); _load(); }
    } catch (err) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$err')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = ref.watch(currentGymRoleProvider)?.isOwnerOrManager ?? false;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('${widget.member.firstName}\'s Enrollments',
            style: const TextStyle(color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.accentBlue),
            tooltip: 'Enroll in plan',
            onPressed: _openEnrollSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue))
            : _error != null && _enrollments.isEmpty
                ? Center(
                    child: ErrorRetryView(message: _error!, onRetry: _load),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    color: AppColors.accentBlue,
                    child: _enrollments.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 120),
                              Center(child: EmptyStateView(icon: Icons.inbox_rounded, title: 'No enrollments yet.\nTap + to enroll this member.')),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _enrollments.length,
                            itemBuilder: (ctx, i) => _EnrollmentCard(
                              enrollment: _enrollments[i],
                              isOwner: isOwner,
                              onFreeze: () => _freeze(_enrollments[i]),
                              onUnfreeze: () => _unfreeze(_enrollments[i]),
                              onRenew: () => _renew(_enrollments[i]),
                            ),
                          ),
                  ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController ctrl,
    String label, {
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.textPrimary),
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

class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({
    required this.enrollment,
    required this.isOwner,
    required this.onFreeze,
    required this.onUnfreeze,
    required this.onRenew,
  });

  final Enrollment enrollment;
  final bool isOwner;
  final VoidCallback onFreeze;
  final VoidCallback onUnfreeze;
  final VoidCallback onRenew;

  @override
  Widget build(BuildContext context) {
    final e = enrollment;
    final statusColor = switch (e.status) {
      'ACTIVE' => AppColors.accentCyan,
      'FROZEN' => AppColors.accentOrange,
      'EXPIRED' => AppColors.accentCoral,
      _ => AppColors.textTertiary,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(e.planName ?? 'Unknown Plan',
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(e.displayStatus,
                    style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (e.startDate != null || e.endDate != null)
            Text(
              '${e.startDate != null ? _fmt(e.startDate!) : '—'}  →  ${e.endDate != null ? _fmt(e.endDate!) : '—'}',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          if (e.isSessionBased && e.sessionsRemaining != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('${e.sessionsRemaining}/${e.sessionsTotal} sessions remaining',
                  style: AppTextStyles.caption.copyWith(color: AppColors.accentCyan)),
            ),
          if (e.dueAmountInr != null && e.dueAmountInr! > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Due: ₹${e.dueAmountInr!.toStringAsFixed(0)}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.accentCoral, fontWeight: FontWeight.w600)),
            ),
          const SizedBox(height: 12),
          // Action row — only shown for actionable statuses
          if (isOwner && (e.isActive || e.isFrozen || e.isExpired))
            Wrap(
              spacing: 8,
              children: [
                if (e.isActive)
                  _ActionChip(label: 'Freeze', icon: Icons.ac_unit_rounded, onTap: onFreeze),
                if (e.isFrozen)
                  _ActionChip(label: 'Unfreeze', icon: Icons.play_circle_outline_rounded, onTap: onUnfreeze),
                if (e.isActive || e.isExpired)
                  _ActionChip(label: 'Renew', icon: Icons.refresh_rounded, onTap: onRenew),
              ],
            ),
        ],
      ),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accentBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.accentBlue),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
