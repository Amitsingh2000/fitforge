import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tokenProvider = StateProvider<String?>((ref) => null);

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

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Print detailed request log
      debugPrint('🚀 [API Request] ${options.method} ${options.baseUrl}${options.path}');
      if (options.data != null) {
        debugPrint('📦 Payload: ${options.data}');
      }
      
      final token = ref.read(tokenProvider);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onResponse: (response, handler) {
      // Print detailed response log
      debugPrint('✅ [API Response] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.baseUrl}${response.requestOptions.path}');
      debugPrint('📄 Data: ${response.data}');

      // Unpack envelope { success: true, data: { ... } } if present
      if (response.data is Map && response.data['success'] == true) {
        // Return only the data portion to callers
        response.data = response.data['data'];
      }
      return handler.next(response);
    },
    onError: (DioException e, handler) {
      // Print detailed error log
      debugPrint('❌ [API Error] ${e.response?.statusCode} ${e.requestOptions.method} ${e.requestOptions.baseUrl}${e.requestOptions.path}');
      debugPrint('⚠️ Response Data: ${e.response?.data}');
      debugPrint('💬 Message: ${e.message}');

      // Map error envelope if present
      if (e.response?.data is Map) {
        final errData = e.response!.data as Map;
        final message = errData['message'];
        
        // Validation errors (400) return messages as a list of strings
        String errMsg = '';
        if (message is List) {
          errMsg = message.join(', ');
        } else if (message is String) {
          errMsg = message;
        } else {
          errMsg = errData['error']?.toString() ?? 'Something went wrong';
        }
        
        // Pass normalized error message inside the exception
        return handler.next(DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: errMsg,
          message: errMsg,
        ));
      }
      return handler.next(e);
    },
  ));

  return dio;
});
