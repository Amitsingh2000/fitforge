import 'package:dio/dio.dart';

/// A consistent, typed failure surfaced to UI from every trainer-flow API call.
///
/// Unlike throwing raw `DioException`, repositories throw [ApiFailure] so a
/// screen can render a distinct message for each situation (session expired vs
/// forbidden vs not-found vs validation vs server blip) instead of a raw
/// status/string. `ApiFailure.fromDio` is the single mapping point.
enum ApiFailureKind { network, unauthorized, forbidden, notFound, validation, server, other }

class ApiFailure implements Exception {
  const ApiFailure({
    required this.kind,
    this.statusCode,
    required this.message,
    this.detail,
    this.cause,
  });

  final ApiFailureKind kind;
  final int? statusCode;

  /// Ready-to-render message for the user.
  final String message;

  /// Raw server-provided detail (may be the same as [message]).
  final String? detail;

  /// The underlying exception (usually a [DioException]).
  final Object? cause;

  /// Network errors and transient 5xx are safe to retry on; auth/forbidden/
  /// not-found/validation are not.
  bool get retryable =>
      kind == ApiFailureKind.network || kind == ApiFailureKind.server;

  /// Maps any thrown object (typically a [DioException]) into an [ApiFailure].
  factory ApiFailure.fromDio(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final isNetwork =
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.cancel;

      final rawDetail = _intFromError(error);

      if (status == 401) {
        return ApiFailure(
          kind: ApiFailureKind.unauthorized,
          statusCode: status,
          message: 'Your session has expired. Please log in again.',
          detail: rawDetail,
          cause: error,
        );
      }
      if (status == 403) {
        return ApiFailure(
          kind: ApiFailureKind.forbidden,
          statusCode: status,
          message: "You don't have permission to view this — you may only "
              'access members assigned to you.',
          detail: rawDetail,
          cause: error,
        );
      }
      if (status == 404) {
        return ApiFailure(
          kind: ApiFailureKind.notFound,
          statusCode: status,
          message: 'This item could not be found.',
          detail: rawDetail,
          cause: error,
        );
      }
      if (status == 400 || status == 422) {
        return ApiFailure(
          kind: ApiFailureKind.validation,
          statusCode: status,
          message: rawDetail ?? 'Some of the submitted fields are invalid.',
          detail: rawDetail,
          cause: error,
        );
      }
      if (status != null && status >= 500) {
        return ApiFailure(
          kind: ApiFailureKind.server,
          statusCode: status,
          message: 'The server hit an error. Please try again shortly.',
          detail: rawDetail,
          cause: error,
        );
      }
      if (isNetwork) {
        return ApiFailure(
          kind: ApiFailureKind.network,
          message: "Couldn't reach the server — it may be waking up (free "
              'hosting can take up to a minute). Please try again.',
          detail: error.error?.toString(),
          cause: error,
        );
      }
      return ApiFailure(
        kind: ApiFailureKind.other,
        statusCode: status,
        message: rawDetail ?? error.message ?? 'Something went wrong.',
        detail: rawDetail,
        cause: error,
      );
    }
    return ApiFailure(
      kind: ApiFailureKind.other,
      message: error.toString(),
      cause: error,
    );
  }

  static String? _intFromError(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message is List && message.isNotEmpty) return message.join(', ');
      if (message is String && message.isNotEmpty) return message;
      final rawError = data['error'];
      if (rawError is String && rawError.isNotEmpty) return rawError;
    }
    return null;
  }

  @override
  String toString() => message;
}

/// Runs [body] and normalizes any thrown error into an [ApiFailure].
/// Already-typed [ApiFailure]s pass through untouched.
Future<T> apiCall<T>(Future<T> Function() body) async {
  try {
    return await body();
  } on ApiFailure {
    rethrow;
  } catch (e) {
    throw ApiFailure.fromDio(e);
  }
}