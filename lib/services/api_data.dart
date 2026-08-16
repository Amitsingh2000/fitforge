/// Shared-response-shape helpers used across service classes.
///
/// The backend returns bare arrays for some list endpoints and an
/// `{ items: [...] }`-style object for others (after the Dio interceptor has
/// unwrapped the `{ success, data }` envelope). These tolerate both shapes so
/// services can parse defensively.

/// Pulls a List out of a response body, accepting a bare list or any of the
/// common container keys the API uses.
List<dynamic> extractList(dynamic data) {
  if (data is List) return data;
  if (data is Map) {
    for (final key in const [
      'items',
      'members',
      'clients',
      'threads',
      'messages',
      'logs',
      'entries',
      'results',
      'data',
    ]) {
      final value = data[key];
      if (value is List) return value;
    }
  }
  return const [];
}

/// Coerces a response body to a Map (defaults to empty map when it isn't one).
Map<String, dynamic> asMap(dynamic data) {
  if (data is Map) return Map<String, dynamic>.from(data);
  return <String, dynamic>{};
}