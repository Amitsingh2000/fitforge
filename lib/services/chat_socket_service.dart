import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/chat_message.dart';

/// Socket.IO real-time gateway for chat — completely separate from the REST
/// [ChatService]. Messages still persist via REST; a socket just pushes live
/// `newMessage` / `typing` / `stopTyping` / `read` events.
///
/// Connects to the `{API_PREFIX}` host's `/chat` namespace with the same access
/// token used for REST (`io(url + '/chat', { auth: { token } })`), then emits
/// `joinThread { threadId }` for each thread the screen wants live updates on
/// (the server verifies actual participation before joining the room).
class ChatSocketService {
  io.Socket? _socket;
  bool _disposed = false;
  String? _joinedThreadId;

  final _messageController = StreamController<ChatMessage>.broadcast();
  final _typingController = StreamController<ChatTypingEvent>.broadcast();
  final _readController = StreamController<ChatReadEvent>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  /// Live events a chat screen subscribes to.
  Stream<ChatMessage> get onNewMessage => _messageController.stream;
  Stream<ChatTypingEvent> get onTyping => _typingController.stream;
  Stream<ChatReadEvent> get onRead => _readController.stream;

  /// Emits `true` on (re)connect and `false` on disconnect/connect-error.
  Stream<bool> get onConnectionChanged => _connectionController.stream;

  bool get isConnected => _socket?.connected ?? false;
  String? get joinedThreadId => _joinedThreadId;

  /// Connects to `{host}/chat` deriving the host from the REST api base URL
  /// (strips the `/api/v1` prefix). Idempotent when already connected.
  void connect({required String token, required String baseUrl}) {
    if (_disposed) return;
    if (_socket?.connected ?? false) return;

    // A previous socket may still be connecting (not yet connected). Dispose
    // it first so repeated connects don't leak sockets/connections.
    final previous = _socket;
    if (previous != null) {
      previous.dispose();
    }

    _socket = io.io(
      _hostFromApiUrl(baseUrl) + '/chat',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableForceNew()
          .build(),
    );

    _socket!.onConnect((_) {
      _emitConnection(true);
      // Re-join the active thread after a reconnect.
      final threadId = _joinedThreadId;
      if (threadId != null) joinThread(threadId);
    });
    _socket!.onDisconnect((_) => _emitConnection(false));
    _socket!.onConnectError((_) => _emitConnection(false));

    _socket!.on('newMessage', (data) {
      if (data is Map) {
        _messageController.add(
            ChatMessage.fromJson(Map<String, dynamic>.from(data)));
      }
    });
    _socket!.on('typing', (data) {
      if (data is Map) {
        _typingController.add(
            ChatTypingEvent.fromJson(Map<String, dynamic>.from(data)));
      }
    });
    _socket!.on('stopTyping', (data) {
      if (data is Map) {
        final e = ChatTypingEvent.fromJson(Map<String, dynamic>.from(data));
        _typingController.add(ChatTypingEvent(
            threadId: e.threadId, userId: e.userId, name: e.name, typing: false));
      }
    });
    _socket!.on('read', (data) {
      if (data is Map) {
        _readController.add(ChatReadEvent.fromJson(Map<String, dynamic>.from(data)));
      }
    });
  }

  /// Emits `joinThread { threadId }` — call when a thread screen opens. The
  /// server verifies the caller is a participant before allowing the room join.
  void joinThread(String threadId) {
    _joinedThreadId = threadId;
    _socket?.emit('joinThread', {'threadId': threadId});
  }

  /// Leaves the live room for the current thread (e.g. when leaving the screen).
  void leaveThread() {
    final threadId = _joinedThreadId;
    _joinedThreadId = null;
    if (threadId != null) {
      _socket?.emit('leaveThread', {'threadId': threadId});
    }
  }

  /// Lets the server broadcast this client's typing state to the other side.
  void emitTyping(String threadId, {required bool typing}) {
    if (typing) {
      _socket?.emit('typing', {'threadId': threadId});
    } else {
      _socket?.emit('stopTyping', {'threadId': threadId});
    }
  }

  /// Clean disconnect — used on logout and when leaving chat screens.
  void disconnect() {
    if (_socket != null) {
      _socket!.dispose(); // disconnect + clear listeners (v3)
      _socket = null;
    }
    _joinedThreadId = null;
    _emitConnection(false);
  }

  /// Adds to the connection stream only while the service is still live —
  /// socket callbacks can fire asynchronously after [dispose] closed the
  /// controllers, and `add` on a closed controller throws.
  void _emitConnection(bool connected) {
    if (_disposed || _connectionController.isClosed) return;
    _connectionController.add(connected);
  }

  /// Tears down the service for good (app teardown only).
  Future<void> dispose() async {
    _disposed = true;
    disconnect();
    await _messageController.close();
    await _typingController.close();
    await _readController.close();
    await _connectionController.close();
  }

  /// Derives the websocket host from the REST base URL: e.g.
  /// `https://host/api/v1` → `https://host` (the namespace lives at `host/chat`).
  static String _hostFromApiUrl(String apiBaseUrl) {
    var host = apiBaseUrl;
    while (host.endsWith('/')) {
      host = host.substring(0, host.length - 1);
    }
    for (final suffix in const ['/api/v1', '/api']) {
      if (host.endsWith(suffix)) {
        host = host.substring(0, host.length - suffix.length);
      }
    }
    return host;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod plumbing — exposes the socket service, a StateNotifier that
// connects/disconnects from chat screens (auto-disposes → clean disconnect on
// leaving the screen), and live event streams the chat UI can subscribe to.
// ─────────────────────────────────────────────────────────────────────────────

enum ChatSocketStatus { disconnected, connecting, connected, error }

class ChatSocketState {
  final ChatSocketStatus status;
  final String? errorMessage;
  final String? joinedThreadId;

  const ChatSocketState({
    this.status = ChatSocketStatus.disconnected,
    this.errorMessage,
    this.joinedThreadId,
  });

  bool get isConnected => status == ChatSocketStatus.connected;

  ChatSocketState copyWith({
    ChatSocketStatus? status,
    String? errorMessage,
    String? joinedThreadId,
  }) {
    return ChatSocketState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      joinedThreadId: joinedThreadId,
    );
  }
}

/// Manages the connection lifecycle around the shared [ChatSocketService].
///
/// `autoDispose` gives free cleanup: when the last chat screen watching this
/// provider closes, the notifier is disposed and disconnects the socket.
class ChatSocketController extends StateNotifier<ChatSocketState> {
  final ChatSocketService service;
  final List<StreamSubscription> _subs = [];

  ChatSocketController(this.service) : super(const ChatSocketState()) {
    _subs.add(service.onConnectionChanged.listen((connected) {
      state = state.copyWith(
        status: connected
            ? ChatSocketStatus.connected
            : ChatSocketStatus.disconnected,
      );
    }));
  }

  /// Connect to the `/chat` namespace using the same token as REST.
  Future<void> connect({
    required String token,
    required String baseUrl,
  }) async {
    if (state.isConnected) return;
    state = state.copyWith(status: ChatSocketStatus.connecting);
    service.connect(token: token, baseUrl: baseUrl);
  }

  void joinThread(String threadId) {
    service.joinThread(threadId);
    state = state.copyWith(joinedThreadId: threadId);
  }

  void leaveThread() {
    service.leaveThread();
    state = state.copyWith(joinedThreadId: null);
  }

  void emitTyping(String threadId, {required bool typing}) =>
      service.emitTyping(threadId, typing: typing);

  void disconnect() {
    service.disconnect();
    state = const ChatSocketState();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    service.disconnect();
    super.dispose();
  }
}

/// Shared socket service instance for the whole app lifetime.
final chatSocketServiceProvider = Provider<ChatSocketService>((ref) {
  final service = ChatSocketService();
  ref.onDispose(service.dispose);
  return service;
});

/// Connection controller a chat screen watches and drives.
final chatSocketProvider = StateNotifierProvider.autoDispose<
    ChatSocketController, ChatSocketState>((ref) {
  return ChatSocketController(ref.watch(chatSocketServiceProvider));
});

/// Live `newMessage` events.
final chatNewMessageProvider = StreamProvider.autoDispose<ChatMessage>((ref) {
  return ref.watch(chatSocketServiceProvider).onNewMessage;
});

/// Live `typing` / `stopTyping` events.
final chatTypingProvider =
    StreamProvider.autoDispose<ChatTypingEvent>((ref) {
  return ref.watch(chatSocketServiceProvider).onTyping;
});

/// Live `read` receipt events.
final chatReadProvider = StreamProvider.autoDispose<ChatReadEvent>((ref) {
  return ref.watch(chatSocketServiceProvider).onRead;
});

/// Live connection status events (true when connected).
final chatConnectionProvider = StreamProvider.autoDispose<bool>((ref) {
  return ref.watch(chatSocketServiceProvider).onConnectionChanged;
});