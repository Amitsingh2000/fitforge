import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';

const _roles = ['MEMBER', 'TRAINER', 'FRONT_DESK', 'GYM_MANAGER'];

String _roleLabel(String role) => switch (role) {
      'MEMBER' => 'Member',
      'TRAINER' => 'Trainer',
      'FRONT_DESK' => 'Front Desk',
      'GYM_MANAGER' => 'Manager',
      _ => role,
    };

/// `POST/GET /gyms/:gymId/invites`, `POST .../invites/:id/revoke` — the
/// mechanism members/staff actually use to join a gym (`POST /gyms/join`).
class InviteManagementScreen extends ConsumerStatefulWidget {
  const InviteManagementScreen({super.key});

  @override
  ConsumerState<InviteManagementScreen> createState() => _InviteManagementScreenState();
}

class _InviteManagementScreenState extends ConsumerState<InviteManagementScreen> {
  List<Map<String, dynamic>> _invites = [];
  bool _loading = true;
  String? _error;

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
      final invites = await ref.read(gymOwnerServiceProvider).getInvites(gymId);
      if (mounted) setState(() { _invites = invites; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = friendlyApiError(e); });
    }
  }

  Future<void> _createInvite() async {
    String role = 'MEMBER';
    final maxUsesController = TextEditingController();
    DateTime? expiresAt;
    try {

    final created = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Invite Code', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Text('Role', style: AppTextStyles.labelSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _roles.map((r) {
                    final selected = r == role;
                    return GestureDetector(
                      onTap: () => setSheetState(() => role = r),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: selected ? AppColors.accentBlue.withValues(alpha: 0.15) : AppColors.bgTertiary,
                          border: Border.all(color: selected ? AppColors.accentBlue : AppColors.glassBorder),
                        ),
                        child: Text(_roleLabel(r),
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: selected ? AppColors.accentBlue : AppColors.textSecondary,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: maxUsesController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Max uses (leave empty for unlimited)',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.bgTertiary,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) setSheetState(() => expiresAt = picked);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.bgTertiary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_outlined, color: AppColors.textTertiary, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          expiresAt == null ? 'No expiry' : 'Expires ${_fmt(expiresAt!)}',
                          style: TextStyle(color: expiresAt == null ? AppColors.textTertiary : AppColors.textPrimary),
                        ),
                        if (expiresAt != null) ...[
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setSheetState(() => expiresAt = null),
                            child: const Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 18),
                          ),
                        ],
                      ],
                    ),
                  ),
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
                    child: const Text('Create Invite', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (created != true) return;
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    try {
      final maxUses = int.tryParse(maxUsesController.text.trim());
      await ref.read(gymOwnerServiceProvider).createInvite(
            gymId,
            role: role,
            maxUses: maxUses,
            expiresAt: expiresAt?.toIso8601String(),
          );
      if (mounted) _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create invite: ${friendlyApiError(e)}')),
        );
      }
    }
    } finally {
      maxUsesController.dispose();
    }
  }

  Future<void> _revoke(Map<String, dynamic> invite) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Revoke this code?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Anyone holding this code or its printed QR will no longer be able to join with it.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Revoke', style: TextStyle(color: AppColors.accentCoral))),
        ],
      ),
    );
    if (confirmed != true) return;
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    try {
      await ref.read(gymOwnerServiceProvider).revokeInvite(gymId, invite['id'] as String);
      if (mounted) _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to revoke: ${friendlyApiError(e)}')),
        );
      }
    }
  }

  void _showQr(Map<String, dynamic> invite) {
    final code = invite['code'] as String? ?? '';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${_roleLabel(invite['role'] as String? ?? '')} Invite', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Scan at the front desk to join', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: QrImageView(data: code, size: 200, backgroundColor: Colors.white),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied')));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(code, style: AppTextStyles.titleMedium.copyWith(letterSpacing: 2, fontFamily: 'monospace')),
                    const SizedBox(width: 10),
                    const Icon(Icons.copy_rounded, color: AppColors.accentBlue, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Invite Codes', style: TextStyle(color: AppColors.textPrimary)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createInvite,
        backgroundColor: AppColors.accentBlue,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Invite', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(message: 'Loading invites…');
    if (_error != null) return ErrorRetryView(message: _error!, onRetry: _load);
    if (_invites.isEmpty) {
      return EmptyStateView(
        icon: Icons.qr_code_2_rounded,
        title: 'No invite codes yet',
        subtitle: 'Create a code so members, trainers, or staff can join your gym.',
        actionLabel: 'Create Invite',
        onAction: _createInvite,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.accentBlue,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: _invites.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _inviteCard(_invites[i]),
      ),
    );
  }

  Widget _inviteCard(Map<String, dynamic> invite) {
    final role = invite['role'] as String? ?? 'MEMBER';
    final code = invite['code'] as String? ?? '';
    final revokedAt = invite['revokedAt'] as String?;
    final expiresAtStr = invite['expiresAt'] as String?;
    final expiresAt = expiresAtStr != null ? DateTime.tryParse(expiresAtStr) : null;
    final maxUses = invite['maxUses'] as int?;
    final usesCount = invite['usesCount'] as int? ?? 0;
    final isRevoked = revokedAt != null;
    final isExpired = expiresAt != null && expiresAt.isBefore(DateTime.now());
    final isInactive = isRevoked || isExpired;

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_roleLabel(role),
                    style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              if (isInactive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.accentCoral.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(isRevoked ? 'Revoked' : 'Expired',
                      style: AppTextStyles.caption.copyWith(color: AppColors.accentCoral, fontWeight: FontWeight.w700)),
                ),
              const Spacer(),
              if (!isInactive)
                IconButton(
                  onPressed: () => _showQr(invite),
                  icon: const Icon(Icons.qr_code_rounded, color: AppColors.textSecondary, size: 20),
                  tooltip: 'Show QR',
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(code, style: AppTextStyles.titleMedium.copyWith(letterSpacing: 1.5, fontFamily: 'monospace')),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.people_outline_rounded, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(maxUses != null ? '$usesCount / $maxUses uses' : '$usesCount uses (unlimited)',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: 14),
              Icon(Icons.event_outlined, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(expiresAt != null ? _fmt(expiresAt) : 'No expiry',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          if (!isInactive) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _revoke(invite),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.accentCoral.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Revoke', style: TextStyle(color: AppColors.accentCoral, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
