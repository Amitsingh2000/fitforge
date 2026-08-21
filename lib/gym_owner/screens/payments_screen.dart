import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/gym_member.dart';
import '../../models/gym_membership.dart';
import '../../models/payment.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/sheet_chrome.dart';
import '../../dashboard/widgets/state_views.dart';

/// Payments & billing screen.
/// Covers: `POST/GET /gyms/:gymId/payments`, void, dues dashboard.
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key, required this.gymId});

  final String gymId;

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  List<GymPayment> _payments = [];
  List<DuesSummary> _dues = [];
  bool _paymentsLoading = true;
  bool _duesLoading = true;
  String? _paymentsError;
  String? _duesError;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPayments();
      _loadDues();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    setState(() { _paymentsLoading = true; _paymentsError = null; });
    try {
      final list = await ref.read(gymOwnerServiceProvider).getPayments(widget.gymId);
      if (mounted) setState(() { _payments = list; _paymentsLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _paymentsLoading = false; _paymentsError = friendlyApiError(e); });
    }
  }

  Future<void> _loadDues() async {
    setState(() { _duesLoading = true; _duesError = null; });
    try {
      final list = await ref.read(gymOwnerServiceProvider).getDuesDashboard(widget.gymId);
      if (mounted) setState(() { _dues = list; _duesLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _duesLoading = false; _duesError = friendlyApiError(e); });
    }
  }

  // ── Record payment sheet ────────────────────────────────────────────────────
  Future<void> _openRecordSheet({DuesSummary? prefill}) async {
    const methods = ['CASH', 'UPI_MANUAL', 'BANK_TRANSFER', 'CARD_OFFLINE', 'OTHER'];
    const methodLabels = ['Cash', 'UPI', 'Bank Transfer', 'Card', 'Other'];
    String selectedMethod = 'CASH';
    final amountCtrl = TextEditingController(
      text: prefill != null && prefill.dueAmountInr > 0
          ? prefill.dueAmountInr.toStringAsFixed(0)
          : '',
    );
    final notesCtrl = TextEditingController();
    GymMember? selectedMember;
    try {
      final members = await ref.read(gymOwnerServiceProvider).getMembers(
            widget.gymId,
            role: 'MEMBER',
          );
      if (prefill?.userId != null) {
        for (final m in members) {
          if (m.userId == prefill!.userId) {
            selectedMember = m;
            break;
          }
        }
      }

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
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
                  const SheetDragHandle(),
                  const SizedBox(height: 16),
                  Text('Record Payment', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  Text('Member', style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<GymMember>(
                    value: selectedMember,
                    isExpanded: true,
                    dropdownColor: AppColors.bgTertiary,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.bgTertiary,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    hint: const Text('Select member', style: TextStyle(color: AppColors.textTertiary)),
                    items: members
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m.fullName, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (m) => setS(() => selectedMember = m),
                  ),
                  const SizedBox(height: 16),
                  Text('Payment Method', style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(methods.length, (i) {
                      final selected = selectedMethod == methods[i];
                      return GestureDetector(
                        onTap: () => setS(() => selectedMethod = methods[i]),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.accentBlue.withValues(alpha: 0.15) : AppColors.bgTertiary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: selected ? AppColors.accentBlue : Colors.transparent),
                          ),
                          child: Text(methodLabels[i],
                              style: AppTextStyles.caption.copyWith(
                                color: selected ? AppColors.accentBlue : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  _inputField(amountCtrl, 'Amount (₹)', hint: '0.00', keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _inputField(notesCtrl, 'Notes (optional)', hint: 'e.g. Month of July'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentCyan,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Record Payment', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
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
      final amount = double.tryParse(amountCtrl.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
        return;
      }
      if (selectedMember == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a member')));
        return;
      }
      try {
        await ref.read(gymOwnerServiceProvider).recordPayment(
          widget.gymId,
          userId: selectedMember!.userId,
          amountInr: amount,
          method: selectedMethod,
          enrollmentId: prefill?.enrollmentId,
          notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment recorded ✓')),
          );
          _loadPayments();
          _loadDues();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
    } finally {
      amountCtrl.dispose();
      notesCtrl.dispose();
    }
  }

  Future<void> _showReceipt(GymPayment payment) async {
    Map<String, dynamic> raw;
    try {
      raw = await ref.read(gymOwnerServiceProvider).getPaymentReceipt(widget.gymId, payment.id);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyApiError(e))));
      return;
    }
    if (!mounted) return;
    final receipt = GymPayment.fromJson(raw);
    final gym = raw['gym'] as Map<String, dynamic>?;
    final gymName = gym?['name'] as String? ?? '';
    final gymAddress = [gym?['addressLine'], gym?['city']].whereType<String>().where((s) => s.isNotEmpty).join(', ');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetDragHandle(),
            const SizedBox(height: 16),
            if (gymName.isNotEmpty) Text(gymName, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
            if (gymAddress.isNotEmpty)
              Text(gymAddress, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 16),
            Center(
              child: Text('₹${receipt.amountInr.toStringAsFixed(0)}',
                  style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800)),
            ),
            if (receipt.isVoided)
              Center(child: Text('VOIDED', style: AppTextStyles.caption.copyWith(color: AppColors.accentCoral, fontWeight: FontWeight.w700))),
            const SizedBox(height: 20),
            _receiptRow('Receipt No.', receipt.receiptNumber),
            _receiptRow('Paid by', receipt.memberName ?? '—'),
            _receiptRow('Method', receipt.methodLabel),
            _receiptRow('Date', receipt.paidAt != null ? '${receipt.paidAt!.day}/${receipt.paidAt!.month}/${receipt.paidAt!.year}' : '—'),
            if (receipt.notes != null && receipt.notes!.isNotEmpty) _receiptRow('Notes', receipt.notes!),
            const SizedBox(height: 16),
            Text('Non-GST manual receipt.', style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary))),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  Future<void> _voidPayment(GymPayment p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Void Payment?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Receipt ${p.receiptNumber} for ₹${p.amountInr.toStringAsFixed(0)} will be voided. This restores dues.',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Void', style: TextStyle(color: AppColors.accentCoral)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(gymOwnerServiceProvider).voidPayment(widget.gymId, p.id);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment voided'))); _loadPayments(); _loadDues(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _showRevenueReport() async {
    Map<String, dynamic>? report;
    try {
      report = await ref.read(gymOwnerServiceProvider).getRevenueReport(widget.gymId);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      return;
    }
    if (!mounted) return;
    final total = report['totalInr'] ?? 0;
    final count = report['paymentCount'] ?? 0;
    final byMethod = (report['byMethod'] as List?) ?? const [];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenue', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('₹$total · $count payments',
                style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            if (byMethod.isEmpty)
              Text('No payments in this range.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary))
            else
              ...byMethod.map((raw) {
                final m = Map<String, dynamic>.from(raw as Map);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text('${m['method'] ?? '—'}', style: AppTextStyles.bodyMedium)),
                      Text('₹${m['totalInr'] ?? 0}  (${m['count'] ?? 0})',
                          style: AppTextStyles.labelLarge),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = ref.watch(currentGymRoleProvider)?.isOwnerOrManager ?? false;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Payments', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          if (isOwner)
            IconButton(
              tooltip: 'Revenue report',
              icon: const Icon(Icons.bar_chart_rounded, color: AppColors.textSecondary),
              onPressed: _showRevenueReport,
            ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.accentCyan,
          labelColor: AppColors.accentCyan,
          unselectedLabelColor: AppColors.textTertiary,
          tabs: const [Tab(text: 'All Payments'), Tab(text: 'Dues')],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRecordSheet,
        backgroundColor: AppColors.accentCyan,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Record Payment', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ── Tab 1: All Payments ───────────────────────────────────────────
          _paymentsLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue))
              : _paymentsError != null && _payments.isEmpty
                  ? Center(child: ErrorRetryView(message: _paymentsError!, onRetry: _loadPayments))
                  : RefreshIndicator(
                      onRefresh: _loadPayments,
                      color: AppColors.accentBlue,
                      child: _payments.isEmpty
                          ? ListView(children: const [SizedBox(height: 120), Center(child: EmptyStateView(icon: Icons.inbox_rounded, title: 'No payments recorded yet.'))])
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                              itemCount: _payments.length,
                              itemBuilder: (ctx, i) => _PaymentTile(
                                payment: _payments[i],
                                isOwner: isOwner,
                                onVoid: isOwner ? () => _voidPayment(_payments[i]) : null,
                                onTap: () => _showReceipt(_payments[i]),
                              ),
                            ),
                    ),
          // ── Tab 2: Dues Dashboard ─────────────────────────────────────────
          _duesLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue))
              : !isOwner
                  ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Dues dashboard is restricted to Owners and Managers.', style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center)))
                  : _duesError != null && _dues.isEmpty
                      ? Center(child: ErrorRetryView(message: _duesError!, onRetry: _loadDues))
                      : RefreshIndicator(
                          onRefresh: _loadDues,
                          color: AppColors.accentBlue,
                          child: _dues.isEmpty
                              ? ListView(children: const [SizedBox(height: 120), Center(child: EmptyStateView(icon: Icons.inbox_rounded, title: 'No outstanding dues. 🎉'))])
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _dues.length,
                                  itemBuilder: (ctx, i) => _DuesTile(due: _dues[i]),
                                ),
                        ),
        ],
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

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment, required this.isOwner, this.onVoid, this.onTap});
  final GymPayment payment;
  final bool isOwner;
  final VoidCallback? onVoid;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = payment;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DashboardGlassCard(
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: p.isVoided
                    ? AppColors.textTertiary.withValues(alpha: 0.1)
                    : AppColors.accentCyan.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                p.isVoided ? Icons.cancel_outlined : Icons.receipt_long_rounded,
                color: p.isVoided ? AppColors.textTertiary : AppColors.accentCyan,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.receiptNumber,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600,
                          decoration: p.isVoided ? TextDecoration.lineThrough : null)),
                  Text('${p.methodLabel}${p.memberName != null ? ' · ${p.memberName}' : ''}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${p.amountInr.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: p.isVoided ? AppColors.textTertiary : AppColors.accentCyan)),
                if (p.isVoided)
                  Text('Voided', style: AppTextStyles.caption.copyWith(color: AppColors.accentCoral)),
              ],
            ),
            if (isOwner && !p.isVoided && onVoid != null)
              IconButton(
                icon: const Icon(Icons.block_rounded, color: AppColors.textTertiary, size: 18),
                tooltip: 'Void payment',
                onPressed: onVoid,
              ),
          ],
        ),
      ),
    );
  }
}

class _DuesTile extends StatelessWidget {
  const _DuesTile({required this.due});
  final DuesSummary due;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DashboardGlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accentCoral.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  due.memberName.isNotEmpty ? due.memberName[0].toUpperCase() : '?',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentCoral, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(due.memberName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  if (due.planName != null)
                    Text(due.planName!, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text('₹${due.dueAmountInr.toStringAsFixed(0)} due',
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.accentCoral, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
