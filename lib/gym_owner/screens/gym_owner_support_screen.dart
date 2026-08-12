import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';
import '../../models/support_request.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';

const _kCategories = ['BILLING', 'TECHNICAL', 'ACCOUNT', 'OTHER'];

const _kStatusColors = {
  'OPEN': AppColors.accentOrange,
  'IN_PROGRESS': AppColors.accentBlue,
  'RESOLVED': AppColors.accentCyan,
};

/// `POST/GET /gyms/:gymId/support` — Settings > Support: submit a request to
/// the platform team and see the gym's own past requests.
class GymOwnerSupportScreen extends ConsumerStatefulWidget {
  const GymOwnerSupportScreen({super.key});

  @override
  ConsumerState<GymOwnerSupportScreen> createState() => _GymOwnerSupportScreenState();
}

class _GymOwnerSupportScreenState extends ConsumerState<GymOwnerSupportScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _category = 'OTHER';

  List<SupportRequest> _requests = [];
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) {
      setState(() { _loading = false; _error = 'No gym selected.'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final requests = await ref.read(gymOwnerServiceProvider).getSupportRequests(gymId);
      if (mounted) setState(() { _requests = requests; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = friendlyApiError(e); });
    }
  }

  Future<void> _submit() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();
    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject and message are required')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final created = await ref.read(gymOwnerServiceProvider).createSupportRequest(
            gymId,
            category: _category,
            subject: subject,
            message: message,
          );
      if (mounted) {
        setState(() {
          _requests = [created, ..._requests];
          _submitting = false;
          _subjectController.clear();
          _messageController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted — our team will get back to you.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: ${friendlyApiError(e)}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Support', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(message: 'Loading support requests…');
    if (_error != null) return ErrorRetryView(message: _error!, onRetry: _load);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        _sectionLabel('NEW REQUEST'),
        const SizedBox(height: 10),
        _buildForm(),
        const SizedBox(height: 28),
        _sectionLabel('YOUR REQUESTS'),
        const SizedBox(height: 10),
        if (_requests.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text('No support requests yet.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
          )
        else
          ..._requests.map(_buildRequestCard),
      ],
    );
  }

  Widget _buildForm() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: _kCategories.map((c) {
              final selected = _category == c;
              return GestureDetector(
                onTap: () => setState(() => _category = c),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selected ? AppColors.accentBlue.withValues(alpha: 0.15) : AppColors.glassBg,
                    border: Border.all(color: selected ? AppColors.accentBlue : AppColors.glassBorder),
                  ),
                  child: Text(
                    c,
                    style: AppTextStyles.caption.copyWith(
                      color: selected ? AppColors.accentBlue : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          _field(_subjectController, 'Subject'),
          const SizedBox(height: 12),
          _field(_messageController, 'Message', maxLines: 4),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Submit Request', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(SupportRequest r) {
    final statusColor = _kStatusColors[r.status] ?? AppColors.textTertiary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DashboardGlassCard(
        padding: const EdgeInsets.all(14),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(r.subject,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: statusColor.withValues(alpha: 0.15),
                  ),
                  child: Text(r.status.replaceAll('_', ' '),
                      style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w700, fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(r.message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 12)),
            if (r.resolutionNotes != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Response: ${r.resolutionNotes}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.accentCyan, fontSize: 11)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(width: 3, height: 16, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: AppColors.primaryGradient)),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w700, letterSpacing: 1.2, fontSize: 11)),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.bgSecondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.glassBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.glassBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.accentBlue)),
      ),
    );
  }
}
