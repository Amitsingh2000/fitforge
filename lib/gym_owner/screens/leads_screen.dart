import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/lead.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';

/// Fitness CRM / Lead Pipeline screen.
/// Covers: `GET/POST/PATCH /gyms/:gymId/leads`, convert, metrics.
class LeadsScreen extends ConsumerStatefulWidget {
  const LeadsScreen({super.key, required this.gymId});

  final String gymId;

  @override
  ConsumerState<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends ConsumerState<LeadsScreen> {
  List<GymLead> _leads = [];
  Map<String, dynamic> _metrics = {};
  bool _loading = true;
  String? _error;
  String? _filterStage;

  static const _stages = ['NEW', 'CONTACTED', 'INTERESTED', 'CONVERTED', 'LOST'];
  static const _sources = ['WALK_IN', 'PHONE', 'INSTAGRAM', 'WEBSITE'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final service = ref.read(gymOwnerServiceProvider);
      final leads = await service.getLeads(widget.gymId, stage: _filterStage);
      final metrics = await service.getLeadMetrics(widget.gymId);
      if (mounted) setState(() { _leads = leads; _metrics = metrics; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = friendlyApiError(e); });
    }
  }

  Future<void> _openAddSheet() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String source = 'WALK_IN';
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
                  Text('Add Lead', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  _inputField(nameCtrl, 'Name *', hint: 'Full name'),
                  const SizedBox(height: 12),
                  _inputField(phoneCtrl, 'Phone', hint: '+91 98765 43210', keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _inputField(emailCtrl, 'Email', hint: 'Optional', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  Text('Source', style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sources.map((s) {
                      final selected = source == s;
                      return GestureDetector(
                        onTap: () => setS(() => source = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.accentBlue.withValues(alpha: 0.15) : AppColors.bgTertiary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: selected ? AppColors.accentBlue : Colors.transparent),
                          ),
                          child: Text(_sourceLabel(s),
                              style: AppTextStyles.caption.copyWith(
                                color: selected ? AppColors.accentBlue : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      );
                    }).toList(),
                  ),
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
                      child: const Text('Add Lead', style: TextStyle(fontWeight: FontWeight.w700)),
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
      if (nameCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required')));
        return;
      }
      try {
        await ref.read(gymOwnerServiceProvider).createLead(
          widget.gymId,
          name: nameCtrl.text.trim(),
          phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
          email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
          source: source,
        );
        if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lead added ✓'))); _load(); }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
    } finally {
      nameCtrl.dispose();
      phoneCtrl.dispose();
      emailCtrl.dispose();
    }
  }

  Future<void> _updateStage(GymLead lead, String newStage) async {
    try {
      await ref.read(gymOwnerServiceProvider).updateLead(widget.gymId, lead.id, stage: newStage);
      if (mounted) _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _convert(GymLead lead) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Convert Lead?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('${lead.name} will be created as a gym member. You can enroll them in a plan afterwards.',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Convert', style: TextStyle(color: AppColors.accentCyan))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(gymOwnerServiceProvider).convertLead(widget.gymId, lead.id);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${lead.name} converted to member ✓'))); _load(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _metrics['total'] as int? ?? _leads.length;
    final converted = _metrics['converted'] as int? ?? _leads.where((l) => l.isConverted).length;
    final rate = total > 0 ? (converted / total * 100).toStringAsFixed(0) : '0';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Lead Pipeline', style: TextStyle(color: AppColors.textPrimary)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        backgroundColor: AppColors.accentBlue,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Lead', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue))
          : _error != null && _leads.isEmpty
              ? Center(child: ErrorRetryView(message: _error!, onRetry: _load))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.accentBlue,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                    children: [
                      // Metrics banner
                      DashboardGlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            _MetricBadge(label: 'Total', value: '$total', color: AppColors.accentBlue),
                            const SizedBox(width: 16),
                            _MetricBadge(label: 'Converted', value: '$converted', color: AppColors.accentCyan),
                            const SizedBox(width: 16),
                            _MetricBadge(label: 'Rate', value: '$rate%', color: AppColors.accentOrange),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Stage filter chips
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _FilterChip(label: 'All', selected: _filterStage == null, onTap: () { setState(() => _filterStage = null); _load(); }),
                            ..._stages.map((s) => _FilterChip(
                                  label: _stageLabel(s),
                                  selected: _filterStage == s,
                                  onTap: () { setState(() => _filterStage = s); _load(); },
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_leads.isEmpty)
                        const Center(child: Padding(padding: EdgeInsets.only(top: 60), child: EmptyStateView(icon: Icons.inbox_rounded, title: 'No leads found.\nTap + to capture your first lead.')))
                      else
                        ..._leads.map((l) => _LeadCard(
                              lead: l,
                              onUpdateStage: (stage) => _updateStage(l, stage),
                              onConvert: l.isConverted ? null : () => _convert(l),
                            )),
                    ],
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

  String _sourceLabel(String s) => switch (s) {
    'WALK_IN' => 'Walk-in',
    'PHONE' => 'Phone',
    'INSTAGRAM' => 'Instagram',
    'WEBSITE' => 'Website',
    _ => s,
  };

  String _stageLabel(String s) => switch (s) {
    'NEW' => 'New',
    'CONTACTED' => 'Contacted',
    'INTERESTED' => 'Interested',
    'CONVERTED' => 'Converted',
    'LOST' => 'Lost',
    _ => s,
  };
}

class _LeadCard extends StatelessWidget {
  const _LeadCard({required this.lead, required this.onUpdateStage, this.onConvert});
  final GymLead lead;
  final void Function(String stage) onUpdateStage;
  final VoidCallback? onConvert;

  static const _stageColors = {
    'NEW': AppColors.accentBlue,
    'CONTACTED': AppColors.accentOrange,
    'INTERESTED': AppColors.accentCyan,
    'CONVERTED': Color(0xFF4CAF50),
    'LOST': AppColors.textTertiary,
  };

  @override
  Widget build(BuildContext context) {
    final l = lead;
    final stageColor = _stageColors[l.stage] ?? AppColors.textTertiary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DashboardGlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stageColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: stageColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(l.stageLabel,
                      style: AppTextStyles.caption.copyWith(color: stageColor, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.source_rounded, size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(l.sourceLabel, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                if (l.phone != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.phone_rounded, size: 12, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(l.phone!, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ],
            ),
            const SizedBox(height: 10),
            // Action row
            Row(
              children: [
                if (!l.isConverted) ...[
                  _StageButton(label: 'Move Stage', onTap: () => _showStagePicker(context)),
                  const SizedBox(width: 8),
                  _StageButton(
                    label: 'Convert →',
                    color: AppColors.accentCyan,
                    onTap: onConvert ?? () {},
                  ),
                ] else
                  Text('✓ Converted', style: AppTextStyles.caption.copyWith(color: AppColors.accentCyan, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          ...['NEW', 'CONTACTED', 'INTERESTED', 'LOST'].map((s) => ListTile(
                leading: CircleAvatar(
                  radius: 8,
                  backgroundColor: _stageColors[s] ?? AppColors.textTertiary,
                ),
                title: Text(_stageLbl(s), style: const TextStyle(color: AppColors.textPrimary)),
                onTap: () { Navigator.pop(ctx); onUpdateStage(s); },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _stageLbl(String s) => switch (s) {
    'NEW' => 'New',
    'CONTACTED' => 'Contacted',
    'INTERESTED' => 'Interested',
    'LOST' => 'Lost',
    _ => s,
  };
}

class _StageButton extends StatelessWidget {
  const _StageButton({required this.label, required this.onTap, this.color = AppColors.accentBlue});
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.headlineMedium.copyWith(color: color, fontWeight: FontWeight.w800)),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentBlue.withValues(alpha: 0.15) : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.accentBlue : AppColors.textTertiary.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? AppColors.accentBlue : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            )),
      ),
    );
  }
}
