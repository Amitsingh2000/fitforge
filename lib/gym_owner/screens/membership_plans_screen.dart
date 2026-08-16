import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';

/// `POST/GET/PATCH/DELETE /gyms/:gymId/plans` — the gym's plan catalog.
/// DELETE is a soft-deactivate (labelled "Retire" in the UI) — past
/// enrollments snapshot their price/duration, so retiring a plan never
/// rewrites history.
class MembershipPlansScreen extends ConsumerStatefulWidget {
  const MembershipPlansScreen({super.key});

  @override
  ConsumerState<MembershipPlansScreen> createState() => _MembershipPlansScreenState();
}

class _MembershipPlansScreenState extends ConsumerState<MembershipPlansScreen> {
  List<Map<String, dynamic>> _plans = [];
  bool _loading = true;
  String? _error;
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plans = await ref.read(gymOwnerServiceProvider).getPlans(gymId, includeInactive: _showInactive);
      if (mounted) setState(() { _plans = plans; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = friendlyApiError(e); });
    }
  }

  Future<void> _openPlanForm({Map<String, dynamic>? existing}) async {
    final nameController = TextEditingController(text: existing?['name'] as String? ?? '');
    final descController = TextEditingController(text: existing?['description'] as String? ?? '');
    final priceController = TextEditingController(
      text: existing != null ? '${existing['priceInr']}' : '',
    );
    final durationController = TextEditingController(
      text: existing != null && existing['durationDays'] != null ? '${existing['durationDays']}' : '',
    );
    final sessionController = TextEditingController(
      text: existing != null && existing['sessionCount'] != null ? '${existing['sessionCount']}' : '',
    );
    String type = existing?['type'] as String? ?? 'DURATION';
    final isEdit = existing != null;
    try {

    final saved = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEdit ? 'Edit Plan' : 'New Plan', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  _labeled('Name', TextField(
                    controller: nameController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _dec('e.g. Quarterly (3 months)'),
                  )),
                  const SizedBox(height: 12),
                  _labeled('Description (optional)', TextField(
                    controller: descController,
                    maxLines: 2,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _dec('What this plan includes'),
                  )),
                  const SizedBox(height: 12),
                  if (!isEdit) ...[
                    Text('Type', style: AppTextStyles.labelSmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _typeChip('DURATION', 'Duration (e.g. months)', type, (v) => setSheetState(() => type = v)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _typeChip('SESSION', 'Session pack (PT)', type, (v) => setSheetState(() => type = v)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (type == 'DURATION')
                      _labeled('Duration (days)', TextField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _dec('e.g. 90'),
                      ))
                    else
                      _labeled('Number of sessions', TextField(
                        controller: sessionController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _dec('e.g. 12'),
                      )),
                    const SizedBox(height: 12),
                  ],
                  _labeled('Price (INR)', TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _dec('e.g. 3500'),
                  )),
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
                      child: Text(isEdit ? 'Save Changes' : 'Create Plan', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (saved != true) return;
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    final price = double.tryParse(priceController.text.trim());
    if (price == null || nameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid name and price')));
      }
      return;
    }

    try {
      final service = ref.read(gymOwnerServiceProvider);
      if (isEdit) {
        await service.updatePlan(
          gymId,
          existing['id'] as String,
          name: nameController.text.trim(),
          description: descController.text.trim(),
          priceInr: price,
        );
      } else {
        await service.createPlan(
          gymId,
          name: nameController.text.trim(),
          description: descController.text.trim(),
          type: type,
          durationDays: type == 'DURATION' ? int.tryParse(durationController.text.trim()) : null,
          sessionCount: type == 'SESSION' ? int.tryParse(sessionController.text.trim()) : null,
          priceInr: price,
        );
      }
      if (mounted) _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save plan: ${friendlyApiError(e)}')),
        );
      }
    }
    } finally {
      nameController.dispose();
      descController.dispose();
      priceController.dispose();
      durationController.dispose();
      sessionController.dispose();
    }
  }

  Future<void> _retire(Map<String, dynamic> plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Retire this plan?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '${plan['name']} will no longer be offered to new members. Members already enrolled keep their plan unchanged.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Retire', style: TextStyle(color: AppColors.accentCoral))),
        ],
      ),
    );
    if (confirmed != true) return;
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    try {
      await ref.read(gymOwnerServiceProvider).retirePlan(gymId, plan['id'] as String);
      if (mounted) _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to retire plan: ${friendlyApiError(e)}')),
        );
      }
    }
  }

  Widget _labeled(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.bgTertiary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      );

  Widget _typeChip(String value, String label, String selected, ValueChanged<String> onTap) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.accentBlue.withValues(alpha: 0.15) : AppColors.bgTertiary,
          border: Border.all(color: isSelected ? AppColors.accentBlue : AppColors.glassBorder),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.accentBlue : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
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
        title: const Text('Membership Plans', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: Icon(_showInactive ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.textSecondary),
            tooltip: _showInactive ? 'Hide retired plans' : 'Show retired plans',
            onPressed: () {
              setState(() => _showInactive = !_showInactive);
              _load();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openPlanForm(),
        backgroundColor: AppColors.accentBlue,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Plan', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(message: 'Loading plans…');
    if (_error != null) return ErrorRetryView(message: _error!, onRetry: _load);
    if (_plans.isEmpty) {
      return EmptyStateView(
        icon: Icons.card_membership_outlined,
        title: 'No membership plans yet',
        subtitle: 'Create pricing tiers (e.g. Quarterly, PT Pack) that members can be enrolled in.',
        actionLabel: 'Create Plan',
        onAction: () => _openPlanForm(),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.accentBlue,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: _plans.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _planCard(_plans[i]),
      ),
    );
  }

  Widget _planCard(Map<String, dynamic> plan) {
    final type = plan['type'] as String? ?? 'DURATION';
    final isActive = plan['isActive'] as bool? ?? true;
    final price = plan['priceInr'];
    final sub = type == 'DURATION' ? '${plan['durationDays'] ?? '?'} days' : '${plan['sessionCount'] ?? '?'} sessions';

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(plan['name'] as String? ?? 'Plan', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
              ),
              if (!isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.textTertiary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text('Retired', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          if ((plan['description'] as String?)?.isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            Text(plan['description'] as String, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.accentBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('₹$price', style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Icon(type == 'DURATION' ? Icons.calendar_month_rounded : Icons.fitness_center_rounded, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(sub, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _openPlanForm(existing: plan),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.accentBlue),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Edit', style: TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _retire(plan),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.accentCoral.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Retire', style: TextStyle(color: AppColors.accentCoral, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
