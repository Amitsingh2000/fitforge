import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/token_storage_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated(User user) =>
      AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.error(String message) =>
      AuthState(status: AuthStatus.error, errorMessage: message);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(AuthState.initial());

  // ──────────────────────────────────────────────────────────────────────────
  // SESSION RESTORE — called once on app startup
  // ──────────────────────────────────────────────────────────────────────────

  /// Reads persisted tokens from secure storage and restores the session
  /// without requiring the user to log in again.
  Future<void> tryRestoreSession() async {
    final storedAccess = await tokenStorageService.getAccessToken();
    final storedRefresh = await tokenStorageService.getRefreshToken();

    if (storedAccess == null || storedRefresh == null) {
      state = AuthState.unauthenticated();
      return;
    }

    // Put tokens in memory so the Dio interceptor can use them
    _ref.read(tokenProvider.notifier).state = storedAccess;
    _ref.read(refreshTokenProvider.notifier).state = storedRefresh;

    try {
      final dio = _ref.read(dioProvider);
      final userResponse = await dio.get('/users/me');
      final userData = userResponse.data as Map<String, dynamic>;
      final user = User.fromBackendJson(userData, token: storedAccess);
      state = AuthState.authenticated(user);
    } on DioException catch (e) {
      // 401 will auto-refresh inside the interceptor.  If we still land here
      // it means both tokens are expired — force the user to log in.
      if (e.response?.statusCode == 401) {
        await _clearSession();
        state = AuthState.unauthenticated();
      } else {
        // Network error etc — stay authenticated optimistically
        state = AuthState.unauthenticated();
      }
    } catch (_) {
      state = AuthState.unauthenticated();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  /// Stores both tokens in memory AND secure storage.
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    _ref.read(tokenProvider.notifier).state = accessToken;
    _ref.read(refreshTokenProvider.notifier).state = refreshToken;
    await tokenStorageService.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Clears tokens from memory AND secure storage.
  Future<void> _clearSession() async {
    _ref.read(tokenProvider.notifier).state = null;
    _ref.read(refreshTokenProvider.notifier).state = null;
    await tokenStorageService.clearTokens();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // LOGIN
  // ──────────────────────────────────────────────────────────────────────────

  /// Shared login path: POST /auth/login + GET /users/me + token persist.
  /// [requiredRole] is a client-side UX check only (server enforces real
  /// authorization on every subsequent call) — it lets the trainer/gym-owner
  /// login screens reject an account of the wrong type with a clear message
  /// instead of silently landing them on the wrong dashboard.
  Future<void> _performLogin(
    String email,
    String password, {
    UserRole? requiredRole,
    String? wrongRoleMessage,
  }) async {
    state = AuthState.loading();
    if (email.isEmpty || password.isEmpty) {
      state = AuthState.error('Email and password cannot be empty.');
      return;
    }
    try {
      final dio = _ref.read(dioProvider);
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final tokenData = response.data as Map<String, dynamic>;
      final accessToken = tokenData['accessToken'] as String;
      final refreshToken = tokenData['refreshToken'] as String;

      await _saveTokens(accessToken, refreshToken);

      final userResponse = await dio.get('/users/me');
      final userData = userResponse.data as Map<String, dynamic>;

      final user = User.fromBackendJson(userData, token: accessToken);

      if (requiredRole != null && user.role != requiredRole) {
        await _clearSession();
        state = AuthState.error(wrongRoleMessage ?? 'Access denied.');
        return;
      }

      state = AuthState.authenticated(user);
    } on DioException catch (e) {
      state = AuthState.error(e.message ?? 'Login failed');
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// Re-fetches `GET /users/me` and refreshes the in-memory user — used
  /// after profile edits (name/phone/avatar/onboarding) so the UI reflects
  /// the save immediately instead of showing stale data until next login.
  Future<void> refreshUser() async {
    if (state.status != AuthStatus.authenticated) return;
    try {
      final dio = _ref.read(dioProvider);
      final token = _ref.read(tokenProvider);
      final userResponse = await dio.get('/users/me');
      final userData = userResponse.data as Map<String, dynamic>;
      final user = User.fromBackendJson(userData, token: token);
      state = AuthState.authenticated(user);
    } catch (_) {
      // Keep the existing state — a transient failure here shouldn't log
      // the user out or blank the screen.
    }
  }

  Future<void> login(String email, String password) =>
      _performLogin(email, password);

  Future<void> loginAsTrainer(String email, String password) => _performLogin(
        email,
        password,
        requiredRole: UserRole.trainer,
        wrongRoleMessage: 'Access denied. You are not registered as a Trainer.',
      );

  Future<void> loginAsGymOwner(String email, String password) => _performLogin(
        email,
        password,
        requiredRole: UserRole.gymOwner,
        wrongRoleMessage: 'Access denied. You are not registered as a Gym Owner.',
      );

  // ──────────────────────────────────────────────────────────────────────────
  // REGISTER
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> register(
      String firstName, String lastName, String email, String password) async {
    state = AuthState.loading();
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      state = AuthState.error('All fields are required.');
      return;
    }
    if (!email.contains('@')) {
      state = AuthState.error('Please enter a valid email address.');
      return;
    }
    if (password.length < 8) {
      state = AuthState.error('Password must be at least 8 characters.');
      return;
    }
    try {
      final dio = _ref.read(dioProvider);
      final response = await dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      });

      final tokenData = response.data as Map<String, dynamic>;
      final accessToken = tokenData['accessToken'] as String;
      final refreshToken = tokenData['refreshToken'] as String;

      await _saveTokens(accessToken, refreshToken);

      final userResponse = await dio.get('/users/me');
      final userData = userResponse.data as Map<String, dynamic>;

      final user = User.fromBackendJson(userData, token: accessToken);
      // Navigate to email verification — UI layer handles this via status
      state = AuthState.authenticated(user);
    } on DioException catch (e) {
      state = AuthState.error(e.message ?? 'Registration failed');
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // LOGOUT — revokes the server-side refresh token
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    final storedRefreshToken = _ref.read(refreshTokenProvider);

    // Optimistically clear local state first so the UI transitions immediately
    await _clearSession();
    state = AuthState.unauthenticated();

    // Then revoke the server session (best-effort — don't block on failure)
    if (storedRefreshToken != null) {
      try {
        final dio = _ref.read(dioProvider);
        await dio.post('/auth/logout',
            data: {'refreshToken': storedRefreshToken});
      } catch (e) {
        // Ignore — local session is already cleared
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // RESTORE TOKENS FROM GOOGLE OAUTH CALLBACK
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> handleOAuthCallback({
    required String accessToken,
    required String refreshToken,
  }) async {
    state = AuthState.loading();
    try {
      await _saveTokens(accessToken, refreshToken);

      final dio = _ref.read(dioProvider);
      final userResponse = await dio.get('/users/me');
      final userData = userResponse.data as Map<String, dynamic>;

      final user = User.fromBackendJson(userData, token: accessToken);
      state = AuthState.authenticated(user);
    } on DioException catch (e) {
      await _clearSession();
      state = AuthState.error(e.message ?? 'OAuth login failed');
    } catch (e) {
      await _clearSession();
      state = AuthState.error(e.toString());
    }
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
