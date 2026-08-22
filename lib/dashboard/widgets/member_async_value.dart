import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'state_views.dart';

/// Standard loading / error / data wrapper for member FutureProviders.
class MemberAsyncValue<T> extends StatelessWidget {
  const MemberAsyncValue({
    super.key,
    required this.value,
    required this.builder,
    this.loadingMessage,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final String? loadingMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => LoadingView(message: loadingMessage),
      error: (e, _) => ErrorRetryView(
        message: friendlyApiError(e),
        onRetry: onRetry ?? () {},
      ),
      data: builder,
    );
  }
}
