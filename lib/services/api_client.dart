import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'token_storage_service.dart';

// ─────────────────────────────────────────────
// In-memory token providers (source of truth for the current session)
// ─────────────────────────────────────────────

final tokenProvider = StateProvider<String?>((ref) => null);
final refreshTokenProvider = StateProvider<String?>((ref) => null);

/// Thrown internally when a token refresh resolves after the session changed
/// (logout or new login). Distinguishes a stale response — where the new
/// session's tokens must be left untouched — from a genuine refresh failure.
class _StaleRefreshException implements Exception {
  const _StaleRefreshException();
  @override
  String toString() => 'Session changed during token refresh.';
}

void _log(String message) {
  if (kDebugMode) debugPrint(message);
}

// ─────────────────────────────────────────────
// Dio provider with full interceptor chain
// ─────────────────────────────────────────────

/// Override with `--dart-define=API_BASE=http://127.0.0.1:3000/api/v1` for local GymOS.
const kApiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'https://fitos-backend-55g6.onrender.com/api/v1',
);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: kApiBase,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  // Shared in-flight refresh so concurrent 401s (e.g. two screens' requests
  // failing together right as the access token expires) await one refresh
  // call instead of each firing their own. The backend rotates-and-invalidates
  // refresh tokens on every use, so a second independent refresh call would
  // present an already-consumed token and be treated as theft — revoking
  // every session. All concurrent 401 handlers must share this one Future.
  Future<String>? refreshInFlight;

  Future<String> refreshAccessToken() {
    return refreshInFlight ??= () async {
      final storedRefreshToken = ref.read(refreshTokenProvider);
      if (storedRefreshToken == null) {
        throw StateError('No refresh token available.');
      }
      try {
        // Snapshot the current refresh token so we can detect a session change
        // (logout / new login) while the refresh call is in flight. The backend
        // rotates refresh tokens on every use, so applying a stale response to
        // a newer session would clobber the new user's credentials.
        final refreshDio = Dio(BaseOptions(
          baseUrl: 'https://fitos-backend-55g6.onrender.com/api/v1',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ));

        final refreshResponse = await refreshDio.post('/auth/refresh',
            data: {'refreshToken': storedRefreshToken});

        final respData = refreshResponse.data;
        Map<String, dynamic> tokenData;
        if (respData is Map && respData['success'] == true) {
          tokenData = Map<String, dynamic>.from(respData['data'] as Map);
        } else {
          tokenData = Map<String, dynamic>.from(respData as Map);
        }

        final newAccessToken = tokenData['accessToken'] as String;
        final newRefreshToken =
            tokenData['refreshToken'] as String? ?? storedRefreshToken;

        // Guard against a stale refresh overwriting a session that was cleared
        // (logout) or replaced (new login) while this call was in flight.
        if (ref.read(refreshTokenProvider) != storedRefreshToken) {
          _log('⚠️ [Auth] Refresh response stale — session changed, discarding.');
          throw const _StaleRefreshException();
        }

        ref.read(tokenProvider.notifier).state = newAccessToken;
        ref.read(refreshTokenProvider.notifier).state = newRefreshToken;
        await tokenStorageService.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        _log('✅ [Auth] Token refreshed successfully.');
        return newAccessToken;
      } catch (refreshError) {
        _log('❌ [Auth] Token refresh failed: $refreshError — logging out.');
        // If the session changed while refresh was in flight (logout or a new
        // login), do NOT clobber the newer session's tokens/storage.
        if (refreshError is! _StaleRefreshException &&
            ref.read(refreshTokenProvider) == storedRefreshToken) {
          ref.read(tokenProvider.notifier).state = null;
          ref.read(refreshTokenProvider.notifier).state = null;
          await tokenStorageService.clearTokens();
        }
        rethrow;
      } finally {
        refreshInFlight = null;
      }
    }();
  }

  // ── 1. Request interceptor: attach Bearer token ──────────────────────────
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      _log('🚀 [API Request] ${options.method} ${options.baseUrl}${options.path}');
      if (options.data != null) {
        _log('📦 Payload: ${options.data}');
      }

      final token = ref.read(tokenProvider);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },

    // ── 2. Response interceptor: unwrap { success, data } envelope ─────────
    onResponse: (response, handler) {
      _log('✅ [API Response] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.baseUrl}${response.requestOptions.path}');
      _log('📄 Data: ${response.data}');

      if (response.data is Map && response.data['success'] == true) {
        response.data = response.data['data'];
      }
      return handler.next(response);
    },

    // ── 3. Error interceptor: refresh token on 401, normalize errors ───────
    onError: (DioException e, handler) async {
      final statusCode = e.response?.statusCode;

      // ── Token refresh logic ──────────────────────────────────────────────
      if (statusCode == 401) {
        final storedRefreshToken = ref.read(refreshTokenProvider);
        final isAuthEndpoint = e.requestOptions.path.startsWith('/auth/');

        if (storedRefreshToken != null && !isAuthEndpoint) {
          try {
            final newAccessToken = await refreshAccessToken();
            final retryOptions = e.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await dio.fetch(retryOptions);
            return handler.resolve(retryResponse);
          } on _StaleRefreshException {
            // The session changed (logout/new login) while refresh was in
            // flight — propagate the original 401 without touching auth state.
          } catch (_) {
            // Both tokens are expired. Tokens/storage were already cleared
            // by refreshAccessToken; flip the whole app to the login screen so
            // the UI stops showing an authenticated dashboard that can never
            // authenticate again.
            ref.read(authProvider.notifier).handleSessionExpired();
          }
        }
      }

      // ── Error message normalization ──────────────────────────────────────
      if (e.response?.data is Map) {
        final errData = e.response!.data as Map;
        final message = errData['message'];

        String errMsg;
        if (message is List) {
          errMsg = message.join(', ');
        } else if (message is String) {
          errMsg = message;
        } else {
          errMsg = errData['error']?.toString() ?? 'Something went wrong';
        }

        _log('❌ [API Error] $statusCode ${e.requestOptions.method} ${e.requestOptions.path} — $errMsg');

        return handler.next(DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: errMsg,
          message: errMsg,
        ));
      }

      _log('❌ [API Error] $statusCode ${e.requestOptions.method} ${e.requestOptions.path}');
      _log('💬 Message: ${e.message}');
      return handler.next(e);
    },
  ));

  return dio;
});
