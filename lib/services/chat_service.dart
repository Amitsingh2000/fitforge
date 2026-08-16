import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/chat_thread.dart';
import 'api_client.dart';
import 'api_data.dart';
import 'api_failure.dart';

/// § Chat — REST half (persistence + broadcast).
///
/// Real-time lives in [ChatSocketService]; this service only persists and reads
/// messages. The socket service must never be merged into this class.
class ChatService {
  final Dio dio;
  ChatService(this.dio);

  /// `POST /gyms/:gymId/chat/threads { otherUserId }` — get-or-create a
  /// two-person thread with the other member.
  Future<ChatThread> createOrGetThread(
    String gymId, {
    required String otherUserId,
  }) =>
      apiCall(() async {
        final res = await dio.post('/gyms/$gymId/chat/threads', data: {
          'otherUserId': otherUserId,
        });
        return ChatThread.fromJson(asMap(res.data));
      });

  /// `GET /gyms/:gymId/chat/threads` — current trainer's thread list.
  Future<List<ChatThread>> getThreads(String gymId) => apiCall(() async {
        final res = await dio.get('/gyms/$gymId/chat/threads');
        return extractList(res.data)
            .whereType<Map>()
            .map((e) => ChatThread.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });

  /// `GET /gyms/:gymId/chat/threads/:id/messages`.
  Future<List<ChatMessage>> getMessages(String gymId, String threadId) =>
      apiCall(() async {
        final res = await dio.get('/gyms/$gymId/chat/threads/$threadId/messages');
        return extractList(res.data)
            .whereType<Map>()
            .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });

  /// `POST /gyms/:gymId/chat/threads/:id/messages`.
  ///
  /// `type: TEXT` for plain messages/feedback; attach a plan directly via
  /// `WORKOUT_PLAN_REF` + [refWorkoutPlanId] or `DIET_PLAN_REF` +
  /// [refDietPlanId].
  Future<ChatMessage> sendMessage(
    String gymId,
    String threadId, {
    String type = 'TEXT',
    String? body,
    String? refWorkoutPlanId,
    String? refDietPlanId,
  }) =>
      apiCall(() async {
        final message = ChatMessage(
          id: '',
          threadId: threadId,
          senderId: '',
          type: type,
          body: body ?? '',
          refWorkoutPlanId: refWorkoutPlanId,
          refDietPlanId: refDietPlanId,
        );
        final res =
            await dio.post('/gyms/$gymId/chat/threads/$threadId/messages', data: message.toSendPayload());
        return ChatMessage.fromJson(asMap(res.data));
      });

  /// `POST /gyms/:gymId/chat/broadcast { body }` — fans out to every active
  /// client of this trainer at this gym.
  Future<void> broadcast(
    String gymId, {
    required String body,
  }) =>
      apiCall(() async {
        await dio.post('/gyms/$gymId/chat/broadcast', data: {'body': body});
      });
}

/// Riverpod provider for [ChatService].
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(ref.watch(dioProvider));
});