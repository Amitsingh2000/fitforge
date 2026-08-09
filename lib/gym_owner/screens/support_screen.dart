import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/support_ticket.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';

/// Gym Owner Support Tickets screen.
/// Source: `POST/GET /gyms/:gymId/support`
class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  List<SupportTicket> _tickets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await ref.read(gymOwnerServiceProvider).getSupportTickets(gymId);
      if (mounted) {
        setState(() {
          _tickets = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = friendlyApiError(e);
        });
      }
    }
  }

  Future<void> _openCreateTicketSheet() async {
    final subjectCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'MEDIUM';
    bool submitting = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final bottomPadding = MediaQuery.of(ctx).viewInsets.bottom;
          return Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 28 + bottomPadding),
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Raise Support Ticket', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: subjectCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Subject *',
                      filled: true,
                      fillColor: AppColors.bgPrimary,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Description *',
                      filled: true,
                      fillColor: AppColors.bgPrimary,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Priority', style: AppTextStyles.labelSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: ['LOW', 'MEDIUM', 'HIGH', 'URGENT'].map((p) {
                      final selected = priority == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(p, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 11)),
                          selected: selected,
                          selectedColor: AppColors.accentBlue,
                          backgroundColor: AppColors.bgPrimary,
                          onSelected: (val) {
                            if (val) setS(() => priority = p);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitting
                          ? null
                          : () async {
                              final gymId = ref.read(currentGymIdProvider);
                              if (gymId == null) return;
                              if (subjectCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill subject and description')));
                                return;
                              }
                              setS(() => submitting = true);
                              try {
                                await ref.read(gymOwnerServiceProvider).createSupportTicket(
                                      gymId,
                                      subject: subjectCtrl.text.trim(),
                                      description: descCtrl.text.trim(),
                                      priority: priority,
                                    );
                                if (ctx.mounted) Navigator.pop(ctx);
                                _load();
                              } catch (e) {
                                setS(() => submitting = false);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Failed: ${friendlyApiError(e)}')));
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: submitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Submit Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.glassBg,
                        border: Border.all(color: AppColors.glassBorder, width: 1),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Help & Support', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800)),
                      Text('Platform support tickets', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.accentBlue, size: 28),
                    onPressed: _openCreateTicketSheet,
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentCoral)))
                      : _tickets.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                                itemCount: _tickets.length,
                                itemBuilder: (context, index) {
                                  final ticket = _tickets[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildTicketCard(ticket),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.headset_mic_rounded, size: 64, color: AppColors.accentBlue.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('No support tickets', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Need assistance? Tap + above to submit a ticket.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    Color statusColor = AppColors.accentCyan;
    if (ticket.status == 'OPEN') statusColor = AppColors.accentOrange;
    if (ticket.status == 'IN_PROGRESS') statusColor = AppColors.accentBlue;
    if (ticket.status == 'RESOLVED' || ticket.status == 'CLOSED') statusColor = AppColors.accentCyan;

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ticket.subject,
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: statusColor.withValues(alpha: 0.15),
                ),
                child: Text(
                  ticket.status,
                  style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w700, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(ticket.description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13)),
          if (ticket.resolutionNotes != null && ticket.resolutionNotes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.accentCyan.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resolution Note:', style: AppTextStyles.caption.copyWith(color: AppColors.accentCyan, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(ticket.resolutionNotes!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontSize: 13)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
