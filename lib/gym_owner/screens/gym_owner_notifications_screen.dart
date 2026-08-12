import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';
import '../../models/owner_notification.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';

const _kNotificationIcons = {
  'OWNER_JOIN_REQUEST': Icons.person_add_rounded,
  'OWNER_RENEWAL_DUE': Icons.event_repeat_rounded,
  'OWNER_MEMBERSHIP_EXPIRED': Icons.event_busy_rounded,
  'OWNER_COUPON_REDEEMED': Icons.confirmation_number_rounded,
  'OWNER_TRAINER_JOINED': Icons.badge_rounded,
  'OWNER_TRAINER_UPDATE': Icons.edit_note_rounded,
};

/// `GET /gyms/:gymId/dashboard/notifications` — owner-facing in-app alert feed.
class GymOwnerNotificationsScreen extends ConsumerStatefulWidget {
  const GymOwnerNotificationsScreen({super.key});

  @override
  ConsumerState<GymOwnerNotificationsScreen> createState() =>
      _GymOwnerNotificationsScreenState();
}

class _GymOwnerNotificationsScreenState
    extends ConsumerState<GymOwnerNotificationsScreen> {
  List<OwnerNotification> _notifications = [];
  bool _loading = true;
  bool _unreadOnly = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) {
      setState(() { _loading = false; _error = 'No gym selected.'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final notifications = await ref
          .read(gymOwnerServiceProvider)
          .getNotifications(gymId, unreadOnly: _unreadOnly);
      if (mounted) setState(() { _notifications = notifications; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = friendlyApiError(e); });
    }
  }

  Future<void> _markRead(OwnerNotification n) async {
    if (!n.isUnread) return;
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    final index = _notifications.indexWhere((x) => x.id == n.id);
    if (index == -1) return;
    setState(() {
      _notifications[index] = OwnerNotification(
        id: n.id,
        templateType: n.templateType,
        subject: n.subject,
        body: n.body,
        readAt: DateTime.now(),
        createdAt: n.createdAt,
      );
    });
    try {
      await ref.read(gymOwnerServiceProvider).markNotificationRead(gymId, n.id);
    } catch (_) {
      // Non-critical — leave optimistic state, next refresh will resync.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() => _unreadOnly = !_unreadOnly);
                  _load();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _unreadOnly ? AppColors.accentBlue.withValues(alpha: 0.15) : AppColors.glassBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _unreadOnly ? AppColors.accentBlue : AppColors.glassBorder,
                    ),
                  ),
                  child: Text(
                    'Unread only',
                    style: AppTextStyles.caption.copyWith(
                      color: _unreadOnly ? AppColors.accentBlue : AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(message: 'Loading notifications…');
    if (_error != null) return ErrorRetryView(message: _error!, onRetry: _load);
    if (_notifications.isEmpty) {
      return const EmptyStateView(
        icon: Icons.notifications_none_rounded,
        title: 'No notifications',
        subtitle: "You're all caught up.",
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.accentBlue,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final n = _notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => _markRead(n),
              child: DashboardGlassCard(
                padding: const EdgeInsets.all(14),
                borderRadius: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: (n.isUnread ? AppColors.accentBlue : AppColors.textTertiary)
                            .withValues(alpha: 0.15),
                      ),
                      child: Icon(
                        _kNotificationIcons[n.templateType] ?? Icons.notifications_rounded,
                        color: n.isUnread ? AppColors.accentBlue : AppColors.textTertiary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.subject ?? n.body,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: n.isUnread ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            n.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (n.isUnread)
                      Container(
                        margin: const EdgeInsets.only(top: 4, left: 6),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.accentBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ).animate(key: ValueKey(n.id)).fadeIn(duration: 300.ms);
        },
      ),
    );
  }
}
