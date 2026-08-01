import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/gym_member.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import 'enrollment_screen.dart';

/// 360° member view — `GET /gyms/:gymId/members/:membershipId` — plus a staff
/// notes editor (`PATCH .../notes`) and record edit (`PATCH .../profile`).
class MemberDetailScreen extends ConsumerStatefulWidget {
  const MemberDetailScreen({
    super.key,
    required this.gymId,
    required this.membershipId,
    this.initial,
  });

  final String gymId;
  final String membershipId;
  final GymMember? initial;

  @override
  ConsumerState<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends ConsumerState<MemberDetailScreen> {
  GymMember? _member;
  bool _loading = true;
  String? _error;
  bool _removed = false;

  @override
  void initState() {
    super.initState();
    _member = widget.initial;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(gymOwnerServiceProvider);
      final detail = await service.getMemberDetail(widget.gymId, widget.membershipId);
      if (mounted) setState(() { _member = detail; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = _member == null ? _friendlyError(e) : null; // keep showing cached data if we have it
        });
      }
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('timeout')) {
      return "Couldn't reach the server — it may be waking up. Pull to retry.";
    }
    return 'Failed to load member: ${msg.replaceFirst('Exception: ', '')}';
  }

  Future<void> _editNotes() async {
    final controller = TextEditingController();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
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
              Text('Staff Notes', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Private — only visible to gym staff.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 5,
                maxLength: 2000,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g. Prefers evening sessions, injured left knee...',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.bgTertiary,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save Notes', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true && mounted) {
      try {
        await ref.read(gymOwnerServiceProvider).updateMemberNotes(
              widget.gymId,
              widget.membershipId,
              staffNotes: controller.text.trim(),
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notes saved')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save notes: $e')),
          );
        }
      }
    }
  }

  Future<void> _confirmRemove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove member?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'This removes ${_member?.fullName ?? 'this person'} from the gym roster. This cannot be undone from the app.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: AppColors.accentCoral)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(gymOwnerServiceProvider).removeMember(widget.gymId, widget.membershipId);
      _removed = true;
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove member: $e')),
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
        title: Text(_member?.fullName ?? 'Member', style: const TextStyle(color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_alt_outlined, color: AppColors.textSecondary),
            tooltip: 'Staff notes',
            onPressed: _member == null ? null : _editNotes,
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _member == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accentBlue));
    }
    if (_error != null && _member == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: AppColors.textTertiary, size: 48),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (_removed) return const SizedBox.shrink();

    final m = _member!;
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.accentBlue,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DashboardGlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Center(
                    child: Text(
                      m.firstName.isNotEmpty ? m.firstName[0].toUpperCase() : '?',
                      style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.fullName, style: AppTextStyles.titleLarge),
                      const SizedBox(height: 4),
                      Text(m.role, style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue)),
                    ],
                  ),
                ),
                _statusChip(m.status),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard('Contact', [
            _row(Icons.email_outlined, m.email.isNotEmpty ? m.email : 'No email on file'),
            _row(Icons.phone_outlined, m.phone ?? 'No phone on file'),
          ]),
          const SizedBox(height: 12),
          _sectionCard('Membership', [
            _row(Icons.card_membership_outlined, m.planName ?? 'No active plan'),
            _row(Icons.event_available_outlined,
                m.startDate != null ? 'Joined ${_fmt(m.startDate!)}' : 'Join date unknown'),
            _row(Icons.event_busy_outlined,
                m.endDate != null ? 'Expires ${_fmt(m.endDate!)}' : 'No expiry on file'),
          ]),
          if (m.assignedTrainerName != null) ...[
            const SizedBox(height: 12),
            _sectionCard('Trainer', [
              _row(Icons.fitness_center_rounded, m.assignedTrainerName!),
            ]),
          ],
          const SizedBox(height: 16),
          // ── Enrollments action ─────────────────────────────────────────
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EnrollmentScreen(
                  gymId: widget.gymId,
                  member: m,
                ),
              ),
            ),
            child: DashboardGlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.card_membership_rounded, color: AppColors.accentBlue, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Enrollments & Lifecycle',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _confirmRemove,
            icon: const Icon(Icons.person_remove_rounded, color: AppColors.accentCoral),
            label: const Text('Remove from Gym', style: TextStyle(color: AppColors.accentCoral)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: AppColors.accentCoral.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> rows) {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1)),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = switch (status) {
      'ACTIVE' => AppColors.accentCyan,
      'EXPIRED' => AppColors.accentCoral,
      'FROZEN' => AppColors.accentOrange,
      _ => AppColors.textTertiary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(status, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
