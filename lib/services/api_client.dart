import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'token_storage_service.dart';

// ─────────────────────────────────────────────
// In-memory token providers (source of truth for the current session)
// ─────────────────────────────────────────────

final tokenProvider = StateProvider<String?>((ref) => null);
final refreshTokenProvider = StateProvider<String?>((ref) => null);

void _log(String message) {
  if (kDebugMode) debugPrint(message);
}

// ─────────────────────────────────────────────
// Dio provider with full interceptor chain
// ─────────────────────────────────────────────

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://fitos-backend-55g6.onrender.com/api/v1',
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
        ref.read(tokenProvider.notifier).state = null;
        ref.read(refreshTokenProvider.notifier).state = null;
        await tokenStorageService.clearTokens();
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
          } catch (_) {
            // Fall through to propagate the original 401 — refreshAccessToken
            // already cleared local session state on failure.
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
