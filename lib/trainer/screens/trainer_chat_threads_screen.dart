import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/gym_provider.dart';
import '../../providers/trainer_flow_providers.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/ambient_glow_background.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';
import '../widgets/client_gradient.dart';
import 'trainer_chat_conversation_screen.dart';

/// A trainer's chat inbox for the active gym — real thread list, replacing
/// the one-shot fire-and-forget send that used to be the only chat entry
/// point in this module.
class TrainerChatThreadsScreen extends ConsumerWidget {
  const TrainerChatThreadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymId = ref.watch(currentGymIdProvider);
    if (gymId == null) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(backgroundColor: AppColors.bgPrimary, title: const Text('Messages')),
        body: Center(
          child: ErrorRetryView(message: 'No gym selected.', onRetry: () {}),
        ),
      );
    }
    final threadsAsync = ref.watch(chatThreadsProvider(gymId));

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: Text('Messages', style: AppTextStyles.titleLarge),
      ),
      body: Stack(
        children: [
          const AmbientGlowBackground(topColor: AppColors.accentPurple, bottomColor: AppColors.accentBlue),
          threadsAsync.when(
        loading: () => const LoadingView(message: 'Loading conversations…'),
        error: (e, _) => ErrorRetryView(
          message: friendlyApiError(e),
          onRetry: () => ref.invalidate(chatThreadsProvider(gymId)),
        ),
        data: (threads) {
          if (threads.isEmpty) {
            return const EmptyStateView(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No conversations yet',
              subtitle: 'Message a client from their profile to start one.',
            );
          }
          final sorted = threads.toList()
            ..sort((a, b) {
              final aTime = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bTime = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bTime.compareTo(aTime);
            });
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final thread = sorted[index];
              final name = thread.otherUserName ?? 'Member';
              final gradientColors = clientGradient(thread.otherUserId ?? thread.id);
              return DashboardGlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                borderRadius: 16,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TrainerChatConversationScreen(
                      gymId: gymId,
                      threadId: thread.id,
                      otherUserId: thread.otherUserId ?? '',
                      otherUserName: name,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(colors: gradientColors),
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'M',
                          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: AppTextStyles.labelLarge.copyWith(fontSize: 15)),
                          const SizedBox(height: 3),
                          Text(
                            thread.lastMessagePreview ?? 'No messages yet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (thread.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentCoral,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${thread.unreadCount}',
                          style: AppTextStyles.caption.copyWith(color: Colors.white, fontSize: 10),
                        ),
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
