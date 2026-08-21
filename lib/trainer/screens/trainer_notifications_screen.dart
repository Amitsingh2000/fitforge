import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trainer_notification.dart';
import '../../providers/trainer_flow_providers.dart';
import '../../services/trainer_dashboard_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/ambient_glow_background.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';

/// The trainer's in-app alert feed — the notification bell used to be a dead
/// button with no screen behind it despite the dashboard showing an unread
/// count from this exact endpoint.
class TrainerNotificationsScreen extends ConsumerWidget {
  const TrainerNotificationsScreen({super.key});

  IconData _iconFor(String type) {
    switch (type) {
      case 'TRAINER_NEW_MESSAGE':
        return Icons.chat_bubble_rounded;
      case 'TRAINER_NEW_CLIENT_ASSIGNED':
        return Icons.person_add_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _timeAgo(DateTime? d) {
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _markRead(WidgetRef ref, TrainerNotification n) async {
    if (n.read) return;
    try {
      await ref.read(trainerDashboardServiceProvider).markNotificationRead(n.id);
    } catch (_) {
      // Best-effort — a failed mark-read shouldn't block reading the alert.
    } finally {
      ref.invalidate(trainerNotificationsProvider);
      ref.invalidate(trainerDashboardProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(trainerNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: Text('Notifications', style: AppTextStyles.titleLarge),
      ),
      body: Stack(
        children: [
          const AmbientGlowBackground(),
          notificationsAsync.when(
        loading: () => const LoadingView(message: 'Loading notifications…'),
        error: (e, _) => ErrorRetryView(
          message: friendlyApiError(e),
          onRetry: () => ref.invalidate(trainerNotificationsProvider),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyStateView(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications yet',
              subtitle: 'New client assignments and messages will show up here.',
            );
          }
          final sorted = notifications.toList()
            ..sort((a, b) {
              final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bTime.compareTo(aTime);
            });
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final n = sorted[index];
              return DashboardGlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                borderRadius: 16,
                borderColor: n.isUnread ? AppColors.accentCyan.withValues(alpha: 0.3) : null,
                onTap: () => _markRead(ref, n),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentCyan.withValues(alpha: 0.12),
                      ),
                      child: Icon(_iconFor(n.type), color: AppColors.accentCyan, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.title ?? n.body,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 14,
                              fontWeight: n.isUnread ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          if (n.title != null) ...[
                            const SizedBox(height: 2),
                            Text(n.body, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                          ],
                          const SizedBox(height: 4),
                          Text(_timeAgo(n.createdAt), style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                    if (n.isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.accentCoral, shape: BoxShape.circle),
                      ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 40))
                  .slideY(begin: 0.05, end: 0, duration: 400.ms, delay: Duration(milliseconds: index * 40));
            },
          );
        },
      ),
        ],
      ),
    );
  }
}
