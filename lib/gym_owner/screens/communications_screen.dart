import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/communication_log.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';

/// Communications outbox screen.
/// WhatsApp messages appear as `wa.me` tap-to-send cards;
/// staff taps to open WhatsApp, then marks as sent.
/// Covers: `GET /gyms/:gymId/communications`, `/:id/mark-sent`, `/announce`.
class CommunicationsScreen extends ConsumerStatefulWidget {
  const CommunicationsScreen({super.key, required this.gymId});

  final String gymId;

  @override
  ConsumerState<CommunicationsScreen> createState() => _CommunicationsScreenState();
}

class _CommunicationsScreenState extends ConsumerState<CommunicationsScreen> {
  List<CommunicationLog> _logs = [];
  bool _loading = true;
  String? _error;
  bool _pendingOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await ref.read(gymOwnerServiceProvider).getCommunications(
        widget.gymId,
        pendingOnly: _pendingOnly,
      );
      if (mounted) setState(() { _logs = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = friendlyApiError(e); });
    }
  }

  Future<void> _openWaLink(CommunicationLog log) async {
    if (log.waLink == null) return;
    final uri = Uri.tryParse(log.waLink!);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
    }
  }

  Future<void> _markSent(CommunicationLog log) async {
    try {
      await ref.read(gymOwnerServiceProvider).markCommunicationSent(widget.gymId, log.id);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Marked sent for ${log.recipientName} ✓'))); _load(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _openAnnounceSheet() async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    try {

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
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
                Text('Broadcast Announcement', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Sends to all active members via email (+ WhatsApp outbox).',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                _inputField(titleCtrl, 'Title', hint: 'e.g. Holiday Schedule'),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Message', style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: bodyCtrl,
                      maxLines: 5,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Type your announcement...',
                        hintStyle: const TextStyle(color: AppColors.textTertiary),
                        filled: true,
                        fillColor: AppColors.bgTertiary,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ],
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
                    child: const Text('Send Announcement', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved == true && mounted) {
      if (titleCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and message are required')));
        return;
      }
      try {
        await ref.read(gymOwnerServiceProvider).sendAnnouncement(
          widget.gymId,
          title: titleCtrl.text.trim(),
          body: bodyCtrl.text.trim(),
        );
        if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement queued ✓'))); _load(); }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
    } finally {
      titleCtrl.dispose();
      bodyCtrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Communications', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          Row(
            children: [
              Text('Pending', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              Switch(
                value: _pendingOnly,
                onChanged: (v) { setState(() => _pendingOnly = v); _load(); },
                activeColor: AppColors.accentBlue,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAnnounceSheet,
        backgroundColor: AppColors.accentBlue,
        icon: const Icon(Icons.campaign_rounded),
        label: const Text('Announce', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue))
          : _error != null && _logs.isEmpty
              ? Center(child: ErrorRetryView(message: _error!, onRetry: _load))
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.accentBlue,
                  child: _logs.isEmpty
                      ? ListView(children: const [SizedBox(height: 120), Center(child: EmptyStateView(icon: Icons.inbox_rounded, title: 'No messages in outbox.'))])
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, Layout.navClearance(context)),
                          itemCount: _logs.length,
                          itemBuilder: (ctx, i) => _CommTile(
                            log: _logs[i],
                            onSendWa: _logs[i].waLink != null ? () => _openWaLink(_logs[i]) : null,
                            onMarkSent: _logs[i].isPending ? () => _markSent(_logs[i]) : null,
                          ),
                        ),
                ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
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

class _CommTile extends StatelessWidget {
  const _CommTile({required this.log, this.onSendWa, this.onMarkSent});
  final CommunicationLog log;
  final VoidCallback? onSendWa;
  final VoidCallback? onMarkSent;

  @override
  Widget build(BuildContext context) {
    final l = log;
    final isPending = l.isPending;
    final isWa = l.channel == 'WHATSAPP';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DashboardGlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ChannelBadge(channel: l.channel),
                const SizedBox(width: 8),
                _TypeBadge(type: l.messageTypeLabel),
                const Spacer(),
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Pending', style: AppTextStyles.caption.copyWith(color: AppColors.accentOrange, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(l.recipientName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            if (l.subject != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(l.subject!, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            // Action buttons — only for pending WhatsApp messages
            if (isWa && isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onSendWa != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSendWa,
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF25D366)),
                        label: const Text('Send via WhatsApp', style: TextStyle(color: Color(0xFF25D366), fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF25D366)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  if (onMarkSent != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onMarkSent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBlue,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Mark Sent', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChannelBadge extends StatelessWidget {
  const _ChannelBadge({required this.channel});
  final String channel;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (channel) {
      'WHATSAPP' => (Icons.chat_bubble_outline_rounded, const Color(0xFF25D366)),
      'EMAIL' => (Icons.email_outlined, AppColors.accentBlue),
      'SMS' => (Icons.sms_rounded, AppColors.accentOrange),
      _ => (Icons.notifications_rounded, AppColors.textTertiary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(channel, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 10)),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return Text(type, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary));
  }
}
