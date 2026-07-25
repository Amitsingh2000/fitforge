import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/trainer_profile.dart';
import '../../services/media_upload_service.dart';
import '../../services/trainer_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';

/// Certification upload (`POST /trainers/me/certifications`) + status list.
/// Verification is a manual super-admin review — this screen shows exactly
/// where each submission stands: PENDING / VERIFIED / REJECTED (+ reason).
class TrainerCertificationsScreen extends ConsumerStatefulWidget {
  const TrainerCertificationsScreen({super.key});

  @override
  ConsumerState<TrainerCertificationsScreen> createState() => _TrainerCertificationsScreenState();
}

class _TrainerCertificationsScreenState extends ConsumerState<TrainerCertificationsScreen> {
  List<TrainerCertification> _certifications = [];
  String _overallStatus = 'UNVERIFIED';
  bool _loading = true;
  String? _error;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final profile = await ref.read(trainerServiceProvider).getMyProfile();
      if (mounted) {
        setState(() {
          _certifications = profile.certifications;
          _overallStatus = profile.verificationStatus;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = friendlyApiError(e); });
    }
  }

  Future<void> _submitNew() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    final name = result.files.single.name;

    final details = await _promptDetails();
    if (details == null) return;

    setState(() => _uploading = true);
    try {
      final ext = name.split('.').last.toLowerCase();
      final contentType = switch (ext) {
        'pdf' => 'application/pdf',
        'png' => 'image/png',
        _ => 'image/jpeg',
      };
      final fileUrl = await ref.read(mediaUploadServiceProvider).uploadFile(
            file: File(path),
            purpose: 'TRAINER_CERTIFICATION',
            contentType: contentType,
          );
      await ref.read(trainerServiceProvider).submitCertification(
            title: details['title']!,
            issuer: details['issuer'],
            fileUrl: fileUrl,
          );
      if (mounted) {
        setState(() => _uploading = false);
        _load();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: ${friendlyApiError(e)}')),
        );
      }
    }
  }

  Future<Map<String, String>?> _promptDetails() async {
    final titleController = TextEditingController();
    final issuerController = TextEditingController();
    return showModalBottomSheet<Map<String, String>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(color: AppColors.bgSecondary, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Certification Details', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Title *',
                  hintText: 'e.g. ACE Certified Personal Trainer',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.bgTertiary,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: issuerController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Issuer (optional)',
                  hintText: 'e.g. American Council on Exercise',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.bgTertiary,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    Navigator.pop(ctx, {
                      'title': titleController.text.trim(),
                      'issuer': issuerController.text.trim(),
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Submit for Review', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
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
        title: const Text('Certifications & Badges', style: TextStyle(color: AppColors.textPrimary)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploading ? null : _submitNew,
        backgroundColor: AppColors.accentBlue,
        icon: _uploading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.upload_file_rounded),
        label: Text(_uploading ? 'Uploading…' : 'Add Certification', style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(message: 'Loading certifications…');
    if (_error != null) return ErrorRetryView(message: _error!, onRetry: _load);

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.accentBlue,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          _verificationBanner(),
          const SizedBox(height: 20),
          if (_certifications.isEmpty)
            const EmptyStateView(
              icon: Icons.workspace_premium_outlined,
              title: 'No certifications submitted yet',
              subtitle: 'Upload a certificate (PDF or image) to get your verified badge.',
            )
          else
            ..._certifications.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _certCard(c),
                )),
        ],
      ),
    );
  }

  Widget _verificationBanner() {
    final (color, icon, label) = switch (_overallStatus) {
      'VERIFIED' => (AppColors.accentCyan, Icons.verified_rounded, 'Verified Trainer'),
      'PENDING' => (AppColors.accentOrange, Icons.hourglass_top_rounded, 'Verification Pending'),
      'REJECTED' => (AppColors.accentCoral, Icons.error_outline_rounded, 'Verification Rejected'),
      _ => (AppColors.textTertiary, Icons.shield_outlined, 'Not Verified'),
    };
    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 2),
                Text(
                  _overallStatus == 'VERIFIED'
                      ? 'This badge is shown on your public profile.'
                      : 'Verification renews yearly once approved.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _certCard(TrainerCertification c) {
    final (color, label) = switch (c.verificationStatus) {
      'VERIFIED' => (AppColors.accentCyan, 'Verified'),
      'REJECTED' => (AppColors.accentCoral, 'Rejected'),
      _ => (AppColors.accentOrange, 'Pending'),
    };
    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 14,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.description_outlined, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                if (c.issuer != null && c.issuer!.isNotEmpty)
                  Text(c.issuer!, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                if (c.verificationStatus == 'REJECTED' && c.rejectionReason != null) ...[
                  const SizedBox(height: 4),
                  Text('Reason: ${c.rejectionReason}', style: AppTextStyles.caption.copyWith(color: AppColors.accentCoral, fontSize: 11)),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(label, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
