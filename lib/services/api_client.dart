import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'token_storage_service.dart';

// ─────────────────────────────────────────────
// In-memory token providers (source of truth for the current session)
// ─────────────────────────────────────────────

final tokenProvider = StateProvider<String?>((ref) => null);
final refreshTokenProvider = StateProvider<String?>((ref) => null);

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

  // ── 1. Request interceptor: attach Bearer token ──────────────────────────
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      debugPrint(
          '🚀 [API Request] ${options.method} ${options.baseUrl}${options.path}');
      if (options.data != null) {
        debugPrint('📦 Payload: ${options.data}');
      }

      final token = ref.read(tokenProvider);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },

    // ── 2. Response interceptor: unwrap { success, data } envelope ─────────
    onResponse: (response, handler) {
      debugPrint(
          '✅ [API Response] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.baseUrl}${response.requestOptions.path}');
      debugPrint('📄 Data: ${response.data}');

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

        // Don't try to refresh if we're already on auth endpoints
        final path = e.requestOptions.path;
        final isAuthEndpoint = path.startsWith('/auth/');

        if (storedRefreshToken != null && !isAuthEndpoint) {
          debugPrint('🔄 [Auth] Access token expired. Attempting refresh...');
          try {
            // Use a fresh Dio instance so we don't enter an interceptor loop
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

            // Unwrap envelope if present
            if (respData is Map && respData['success'] == true) {
              tokenData = Map<String, dynamic>.from(respData['data'] as Map);
            } else {
              tokenData = Map<String, dynamic>.from(respData as Map);
            }

            final newAccessToken = tokenData['accessToken'] as String;
            final newRefreshToken =
                tokenData['refreshToken'] as String? ?? storedRefreshToken;

            // Update in-memory tokens
            ref.read(tokenProvider.notifier).state = newAccessToken;
            ref.read(refreshTokenProvider.notifier).state = newRefreshToken;

            // Persist new tokens
            await tokenStorageService.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            debugPrint('✅ [Auth] Token refreshed successfully.');

            // Retry the original failed request with the new token
            final retryOptions = e.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await dio.fetch(retryOptions);
            return handler.resolve(retryResponse);
          } catch (refreshError) {
            debugPrint(
                '❌ [Auth] Token refresh failed: $refreshError — logging out.');
            // Clear all stored tokens; the auth provider will detect this
            ref.read(tokenProvider.notifier).state = null;
            ref.read(refreshTokenProvider.notifier).state = null;
            await tokenStorageService.clearTokens();
            // Fall through to propagate the original 401
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

        debugPrint(
            '❌ [API Error] $statusCode ${e.requestOptions.method} ${e.requestOptions.path} — $errMsg');

        return handler.next(DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: errMsg,
          message: errMsg,
        ));
      }

      debugPrint(
          '❌ [API Error] $statusCode ${e.requestOptions.method} ${e.requestOptions.path}');
      debugPrint('💬 Message: ${e.message}');
      return handler.next(e);
    },
  ));

  return dio;
});
