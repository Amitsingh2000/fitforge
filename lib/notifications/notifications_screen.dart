import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/member_notification.dart';
import '../../providers/member_flow_providers.dart';
import '../../services/member_dashboard_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../dashboard/widgets/dashboard_glass_card.dart';
import '../dashboard/widgets/state_views.dart';

/// In-app member notifications from `GET /members/me/notifications`.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  MemberNotificationPage? _page;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page =
          await ref.read(memberDashboardServiceProvider).getNotifications();
      if (mounted) {
        setState(() {
          _page = page;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  Future<void> _markRead(MemberNotification n) async {
    if (!n.isUnread) return;
    try {
      await ref.read(memberDashboardServiceProvider).markNotificationRead(n.id);
      await _load();
      ref.invalidate(todayDashboardProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyApiError(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: Text('Notifications', style: AppTextStyles.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? LoadingView(message: 'Loading notifications…')
          : _error != null
              ? ErrorRetryView(
                  message: friendlyApiError(_error!),
                  onRetry: _load,
                )
              : (_page?.items.isEmpty ?? true)
                  ? EmptyStateView(
                      icon: Icons.notifications_none_rounded,
                      title: 'No notifications yet',
                      subtitle: 'Trainer messages and coaching updates appear here.',
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        Layout.navClearance(context),
                      ),
                      itemCount: _page!.items.length,
                      itemBuilder: (context, index) {
                        final n = _page!.items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: DashboardGlassCard(
                            onTap: () => _markRead(n),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 6, right: 10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: n.isUnread
                                        ? AppColors.accentBlue
                                        : Colors.transparent,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (n.subject != null &&
                                          n.subject!.isNotEmpty)
                                        Text(
                                          n.subject!,
                                          style: AppTextStyles.labelLarge.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      Text(
                                        n.body,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
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
}

final memberNotificationsProvider =
    FutureProvider<MemberNotificationPage>((ref) {
  return ref.watch(memberDashboardServiceProvider).getNotifications();
});
