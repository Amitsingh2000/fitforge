import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/trainer_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';

/// Super-admin queue — `GET /trainers/certifications/pending` +
/// `PATCH /trainers/certifications/:id/review`. Platform-internal; only
/// reachable from Settings when the logged-in user has `isSuperAdmin`.
class CertificationReviewScreen extends ConsumerStatefulWidget {
  const CertificationReviewScreen({super.key});

  @override
  ConsumerState<CertificationReviewScreen> createState() => _CertificationReviewScreenState();
}

class _CertificationReviewScreenState extends ConsumerState<CertificationReviewScreen> {
  List<Map<String, dynamic>> _pending = [];
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
      final items = await ref.read(trainerServiceProvider).getPendingCertifications();
      if (mounted) setState(() { _pending = items; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = friendlyApiError(e); });
    }
  }

  Future<void> _approve(Map<String, dynamic> cert) async {
    try {
      await ref.read(trainerServiceProvider).reviewCertification(cert['id'] as String, approve: true);
      if (mounted) {
        setState(() {
          _pending = _pending.where((c) => c['id'] != cert['id']).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${friendlyApiError(e)}')));
      }
    }
  }

  Future<void> _reject(Map<String, dynamic> cert) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject certification', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Reason (required, shown to the trainer)',
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.bgTertiary,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, reasonController.text.trim().isNotEmpty),
            child: const Text('Reject', style: TextStyle(color: AppColors.accentCoral)),
          ),
        ],
      ),
    );
    reasonController.dispose();
    if (confirmed != true) return;
    try {
      await ref.read(trainerServiceProvider).reviewCertification(
            cert['id'] as String,
            approve: false,
            rejectionReason: reasonController.text.trim(),
          );
      if (mounted) {
        setState(() {
          _pending = _pending.where((c) => c['id'] != cert['id']).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${friendlyApiError(e)}')));
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
        title: const Text('Certification Review Queue', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(message: 'Loading queue…');
    if (_error != null) return ErrorRetryView(message: _error!, onRetry: _load);
    if (_pending.isEmpty) {
      return const EmptyStateView(
        icon: Icons.fact_check_outlined,
        title: 'Queue is empty',
        subtitle: 'No certifications waiting for review.',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.accentBlue,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: _pending.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _buildCard(_pending[i]),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> cert) {
    final trainerProfile = cert['trainerProfile'] as Map?;
    final user = trainerProfile?['user'] as Map?;
    final name = user?['fullName'] as String? ??
        '${user?['firstName'] ?? ''} ${user?['lastName'] ?? ''}'.trim();
    final email = user?['email'] as String? ?? '';

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name.isNotEmpty ? name : 'Trainer', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
          if (email.isNotEmpty) Text(email, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: 10),
          Text(cert['title'] as String? ?? '', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          if ((cert['issuer'] as String?)?.isNotEmpty ?? false)
            Text(cert['issuer'] as String, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _reject(cert),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.accentCoral.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Reject', style: TextStyle(color: AppColors.accentCoral, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _approve(cert),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentCyan,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Approve', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
