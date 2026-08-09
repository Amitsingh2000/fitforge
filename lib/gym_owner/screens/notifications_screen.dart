import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/notification_log.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';

/// Gym Owner Notifications feed screen.
/// Source: `GET/POST /gyms/:gymId/dashboard/notifications[/:logId/read]`
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<NotificationLog> _notifications = [];
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
      if (mounted) setState(() => _loading = false);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await ref
          .read(gymOwnerServiceProvider)
          .getNotifications(gymId, unreadOnly: _unreadOnly);

      if (mounted) {
        setState(() {
          _notifications = list;
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

  Future<void> _markRead(NotificationLog log) async {
    if (log.isRead) return;
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;

    try {
      await ref.read(gymOwnerServiceProvider).markNotificationRead(gymId, log.id);
      setState(() {
        final idx = _notifications.indexWhere((n) => n.id == log.id);
        if (idx != -1) {
          final old = _notifications[idx];
          _notifications[idx] = NotificationLog(
            id: old.id,
            type: old.type,
            title: old.title,
            message: old.message,
            isRead: true,
            createdAt: old.createdAt,
            metadata: old.metadata,
          );
        }
      });
    } catch (_) {}
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
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Activity & alert updates',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Filter unread button
                  GestureDetector(
                    onTap: () {
                      setState(() => _unreadOnly = !_unreadOnly);
                      _load();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: _unreadOnly
                            ? AppColors.accentBlue.withValues(alpha: 0.15)
                            : AppColors.glassBg,
                        border: Border.all(
                          color: _unreadOnly ? AppColors.accentBlue : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        _unreadOnly ? 'Unread' : 'All',
                        style: AppTextStyles.caption.copyWith(
                          color: _unreadOnly ? AppColors.accentBlue : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.05, end: 0, duration: 400.ms),
            ),

            // Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentCoral),
                          ),
                        )
                      : _notifications.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                                itemCount: _notifications.length,
                                itemBuilder: (context, index) {
                                  final item = _notifications[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildNotificationCard(item)
                                        .animate(key: ValueKey(item.id))
                                        .fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 50))
                                        .slideY(begin: 0.05, end: 0, duration: 400.ms),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentBlue.withValues(alpha: 0.05),
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 40,
              color: AppColors.accentBlue.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No notifications',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            _unreadOnly ? 'You have no unread notifications.' : 'Check back later for owner alerts.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationLog item) {
    IconData icon = Icons.notifications_rounded;
    Color color = AppColors.accentBlue;

    if (item.type.contains('JOIN')) {
      icon = Icons.person_add_rounded;
      color = AppColors.accentCyan;
    } else if (item.type.contains('RENEWAL') || item.type.contains('EXPIRED')) {
      icon = Icons.autorenew_rounded;
      color = AppColors.accentCoral;
    } else if (item.type.contains('COUPON')) {
      icon = Icons.local_offer_rounded;
      color = AppColors.accentPurple;
    } else if (item.type.contains('TRAINER')) {
      icon = Icons.fitness_center_rounded;
      color = AppColors.accentOrange;
    }

    return GestureDetector(
      onTap: () => _markRead(item),
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
                borderRadius: BorderRadius.circular(12),
                color: color.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Icon(icon, color: color, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: item.isRead ? AppColors.textSecondary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentCoral,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(item.createdAt),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return diff.inMinutes <= 1 ? 'Just now' : '${diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }
}
