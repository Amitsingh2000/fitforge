import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/chat_message.dart';
import '../../models/diet_plan.dart';
import '../../models/workout_plan.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';
import '../../services/chat_service.dart';
import '../../services/chat_socket_service.dart';
import '../../services/diet_plan_service.dart';
import '../../services/workout_plan_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/ambient_glow_background.dart';
import '../../dashboard/widgets/state_views.dart';

/// One live chat thread with a client. REST loads history; the socket pushes
/// new messages/typing while this screen is open (connect-on-open,
/// disconnect-on-close via [chatSocketProvider]'s autoDispose).
class TrainerChatConversationScreen extends ConsumerStatefulWidget {
  final String gymId;
  final String otherUserId;
  final String otherUserName;

  /// Pass when navigating from an existing thread list row; omit to
  /// get-or-create the thread with [otherUserId] (e.g. from a client profile).
  final String? threadId;

  const TrainerChatConversationScreen({
    super.key,
    required this.gymId,
    required this.otherUserId,
    required this.otherUserName,
    this.threadId,
  });

  @override
  ConsumerState<TrainerChatConversationScreen> createState() =>
      _TrainerChatConversationScreenState();
}

class _TrainerChatConversationScreenState
    extends ConsumerState<TrainerChatConversationScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  String? _threadId;
  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;
  bool _otherTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      var threadId = widget.threadId;
      final chat = ref.read(chatServiceProvider);
      if (threadId == null) {
        final thread =
            await chat.createOrGetThread(widget.gymId, otherUserId: widget.otherUserId);
        threadId = thread.id;
      }
      final messages = await chat.getMessages(widget.gymId, threadId);
      unawaited(chat.markThreadRead(widget.gymId, threadId));

      final token = ref.read(tokenProvider);
      if (token != null) {
        await ref.read(chatSocketProvider.notifier).connect(token: token, baseUrl: kApiBase);
        ref.read(chatSocketProvider.notifier).joinThread(threadId);
      }

      if (!mounted) return;
      setState(() {
        _threadId = threadId;
        _messages = messages;
        _loading = false;
      });
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = friendlyApiError(e);
      });
    }
  }

  void _onLiveMessage(ChatMessage message) {
    if (message.threadId != _threadId) return;
    if (_messages.any((m) => m.id == message.id)) return;
    setState(() => _messages = [..._messages, message]);
    _scrollToEnd();
  }

  void _onTypingEvent(ChatTypingEvent event) {
    if (event.threadId != _threadId) return;
    if (event.userId == ref.read(authProvider).user?.id) return;
    setState(() => _otherTyping = event.typing);
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final threadId = _threadId;
    final text = _input.text.trim();
    if (threadId == null || text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _input.clear();
    ref.read(chatSocketProvider.notifier).emitTyping(threadId, typing: false);
    try {
      final sent = await ref.read(chatServiceProvider).sendMessage(widget.gymId, threadId, body: text);
      if (!mounted) return;
      if (!_messages.any((m) => m.id == sent.id)) {
        setState(() => _messages = [..._messages, sent]);
        _scrollToEnd();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.bgTertiary,
          content: Text('Message failed to send: ${friendlyApiError(e)}',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentCoral)),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _attachPlan() async {
    final threadId = _threadId;
    if (threadId == null || _sending) return;
    List<WorkoutPlan> workouts = const [];
    List<DietPlan> diets = const [];
    try {
      workouts = await ref.read(workoutPlanServiceProvider)
          .getWorkoutPlans(widget.gymId, memberId: widget.otherUserId);
      diets = await ref.read(dietPlanServiceProvider)
          .getDietPlans(widget.gymId, memberId: widget.otherUserId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyApiError(e))));
      return;
    }
    if (!mounted) return;
    if (workouts.isEmpty && diets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No plans to attach. Create one from the client profile.')),
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text('Attach a plan', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...workouts.map((p) => ListTile(
                  leading: const Icon(Icons.fitness_center_rounded, color: AppColors.accentCyan),
                  title: Text(p.title ?? 'Workout', style: const TextStyle(color: AppColors.textPrimary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendPlan(type: 'WORKOUT_PLAN_REF', workoutId: p.id, label: p.title ?? 'Workout plan');
                  },
                )),
            ...diets.map((p) => ListTile(
                  leading: const Icon(Icons.restaurant_rounded, color: AppColors.accentOrange),
                  title: Text(p.title ?? 'Diet', style: const TextStyle(color: AppColors.textPrimary)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendPlan(type: 'DIET_PLAN_REF', dietId: p.id, label: p.title ?? 'Diet plan');
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _sendPlan({
    required String type,
    String? workoutId,
    String? dietId,
    required String label,
  }) async {
    final threadId = _threadId;
    if (threadId == null || _sending) return;
    setState(() => _sending = true);
    try {
      final sent = await ref.read(chatServiceProvider).sendMessage(
            widget.gymId,
            threadId,
            type: type,
            body: label,
            refWorkoutPlanId: workoutId,
            refDietPlanId: dietId,
          );
      if (!mounted) return;
      if (!_messages.any((m) => m.id == sent.id)) {
        setState(() => _messages = [..._messages, sent]);
        _scrollToEnd();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyApiError(e))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep the socket connection alive for as long as this screen watches it.
    ref.watch(chatSocketProvider);
    // ref.listen must be registered during build (not from an async
    // callback) — these are cheap no-ops until a live event actually arrives.
    ref.listen(chatNewMessageProvider, (_, next) {
      final message = next.value;
      if (message != null) _onLiveMessage(message);
    });
    ref.listen(chatTypingProvider, (_, next) {
      final event = next.value;
      if (event != null) _onTypingEvent(event);
    });
    final myId = ref.watch(authProvider).user?.id;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.otherUserName, style: AppTextStyles.titleMedium),
            if (_otherTyping)
              Text('typing…', style: AppTextStyles.caption.copyWith(color: AppColors.accentCyan)),
          ],
        ),
      ),
      body: Stack(
        children: [
          const AmbientGlowBackground(topColor: AppColors.accentBlue, bottomColor: null),
          SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _loading
                  ? const LoadingView(message: 'Loading conversation…')
                  : _error != null
                      ? ErrorRetryView(message: _error!, onRetry: () {
                          setState(() {
                            _loading = true;
                            _error = null;
                          });
                          _init();
                        })
                      : _messages.isEmpty
                          ? EmptyStateView(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: 'No messages yet',
                              subtitle: 'Say hello to ${widget.otherUserName}.',
                            )
                          : ListView.builder(
                              controller: _scroll,
                              padding: const EdgeInsets.all(16),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) =>
                                  _buildBubble(_messages[index], myId),
                            ),
            ),
            _buildComposer(),
          ],
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage message, String? myId) {
    final isMine = message.senderId == myId;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: isMine ? AppColors.primaryGradient : null,
          color: isMine ? null : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: isMine ? null : Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          message.isWorkoutRef
              ? 'Workout: ${message.body.isNotEmpty ? message.body : 'Plan attached'}'
              : message.isDietRef
                  ? 'Diet: ${message.body.isNotEmpty ? message.body : 'Plan attached'}'
                  : message.body,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isMine ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _sending ? null : _attachPlan,
            icon: const Icon(Icons.attach_file_rounded, color: AppColors.textSecondary),
          ),
          Expanded(
            child: TextField(
              controller: _input,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              onChanged: (text) {
                final threadId = _threadId;
                if (threadId == null) return;
                ref.read(chatSocketProvider.notifier).emitTyping(threadId, typing: text.isNotEmpty);
              },
              decoration: InputDecoration(
                hintText: 'Message ${widget.otherUserName}…',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
                filled: true,
                fillColor: AppColors.bgSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sending ? null : _send,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: _sending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
