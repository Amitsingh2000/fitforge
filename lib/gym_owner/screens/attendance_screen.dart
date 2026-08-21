import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/attendance_record.dart';
import '../../models/gym_member.dart';
import '../../models/gym_membership.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';

/// Attendance management screen.
/// Tabs: Today's Check-ins, Calendar (date-picker + CRUD), Absence Alerts.
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key, required this.gymId});

  final String gymId;

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  DateTime _selectedDate = DateTime.now();
  List<AttendanceRecord> _records = [];
  List<AbsenceAlert> _alerts = [];
  bool _recordsLoading = true;
  bool _alertsLoading = true;
  String? _recordsError;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecords();
      _loadAlerts();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  String get _isoDate =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _loadRecords() async {
    setState(() { _recordsLoading = true; _recordsError = null; });
    try {
      final list = await ref.read(gymOwnerServiceProvider).getAttendance(
        widget.gymId,
        date: _isoDate,
      );
      if (mounted) setState(() { _records = list; _recordsLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _recordsLoading = false; _recordsError = friendlyApiError(e); });
    }
  }

  Future<void> _loadAlerts() async {
    setState(() => _alertsLoading = true);
    try {
      final list = await ref.read(gymOwnerServiceProvider).getAbsenceAlerts(widget.gymId);
      if (mounted) setState(() { _alerts = list; _alertsLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _alertsLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accentBlue,
            surface: AppColors.bgSecondary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
      _loadRecords();
    }
  }

  // ── Manual Check-In sheet ───────────────────────────────────────────────────
  Future<void> _openManualCheckIn() async {
    List<GymMember> members = [];
    try {
      members = await ref.read(gymOwnerServiceProvider).getMembers(widget.gymId, role: 'MEMBER', limit: 200);
    } catch (_) {}

    if (!mounted) return;

    GymMember? selected;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manual Check-In', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Check in a member for today.', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                Expanded(
                  child: members.isEmpty
                      ? const Center(child: Text('No members found.', style: TextStyle(color: AppColors.textTertiary)))
                      : ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (ctx, i) {
                            final m = members[i];
                            final isSelected = selected?.membershipId == m.membershipId;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.accentBlue.withValues(alpha: 0.2),
                                child: Text(m.firstName.isNotEmpty ? m.firstName[0] : '?',
                                    style: const TextStyle(color: AppColors.accentBlue)),
                              ),
                              title: Text(m.fullName, style: const TextStyle(color: AppColors.textPrimary)),
                              subtitle: Text(m.email, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                              trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.accentBlue) : null,
                              onTap: () => setS(() => selected = m),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selected == null ? null : () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Check In', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved == true && selected != null && mounted) {
      try {
        await ref.read(gymOwnerServiceProvider).manualCheckIn(widget.gymId, userId: selected!.userId);
        if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${selected!.fullName} checked in ✓'))); _loadRecords(); }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _deleteRecord(AttendanceRecord r) async {
    try {
      await ref.read(gymOwnerServiceProvider).deleteAttendanceEntry(widget.gymId, r.id);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry deleted'))); _loadRecords(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
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
        title: const Text('Attendance', style: TextStyle(color: AppColors.textPrimary)),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.accentBlue,
          labelColor: AppColors.accentBlue,
          unselectedLabelColor: AppColors.textTertiary,
          tabs: const [Tab(text: 'Check-ins'), Tab(text: 'Absence Alerts')],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openManualCheckIn,
        backgroundColor: AppColors.accentBlue,
        icon: const Icon(Icons.how_to_reg_rounded),
        label: const Text('Manual Check-In', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ── Tab 1: Check-ins ─────────────────────────────────────────────
          Column(
            children: [
              // Date picker bar
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: AppColors.accentBlue, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        _isoDate == _todayIso()
                            ? 'Today — $_isoDate'
                            : _isoDate,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down_rounded, color: AppColors.accentBlue),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _recordsLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue))
                    : _recordsError != null && _records.isEmpty
                        ? Center(child: ErrorRetryView(message: _recordsError!, onRetry: _loadRecords))
                        : RefreshIndicator(
                            onRefresh: _loadRecords,
                            color: AppColors.accentBlue,
                            child: _records.isEmpty
                                ? ListView(children: [
                                    const SizedBox(height: 80),
                                    Center(child: EmptyStateView(icon: Icons.inbox_rounded, title: 'No check-ins on $_isoDate')),
                                  ])
                                : ListView.builder(
                                    padding: EdgeInsets.fromLTRB(16, 8, 16, Layout.navClearance(context)),
                                    itemCount: _records.length,
                                    itemBuilder: (ctx, i) => _AttendanceTile(
                                      record: _records[i],
                                      canDelete: isOwner,
                                      onDelete: isOwner ? () => _deleteRecord(_records[i]) : null,
                                    ),
                                  ),
                          ),
              ),
            ],
          ),
          // ── Tab 2: Absence Alerts ─────────────────────────────────────────
          _alertsLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue))
              : _alerts.isEmpty
                  ? ListView(children: const [SizedBox(height: 120), Center(child: EmptyStateView(icon: Icons.inbox_rounded, title: 'No absence alerts. All members are active! 💪'))])
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _alerts.length,
                      itemBuilder: (ctx, i) => _AbsenceTile(alert: _alerts[i]),
                    ),
        ],
      ),
    );
  }

  String _todayIso() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({required this.record, required this.canDelete, this.onDelete});
  final AttendanceRecord record;
  final bool canDelete;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DashboardGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.accentBlue.withValues(alpha: 0.15),
              child: Text(
                record.memberName.isNotEmpty ? record.memberName[0].toUpperCase() : '?',
                style: const TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.memberName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  Text(record.methodLabel, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (canDelete && onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accentCoral, size: 20),
                tooltip: 'Delete entry',
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}

class _AbsenceTile extends StatelessWidget {
  const _AbsenceTile({required this.alert});
  final AbsenceAlert alert;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DashboardGlassCard(
        padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_off_rounded, color: AppColors.accentOrange, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.memberName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                if (alert.lastVisitedOn != null)
                  Text('Last seen ${alert.daysSinceLastVisit} days ago',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${alert.daysSinceLastVisit}d',
                style: AppTextStyles.caption.copyWith(color: AppColors.accentOrange, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      ),
    );
  }
}
