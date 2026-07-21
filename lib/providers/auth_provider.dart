import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../services/api_client.dart';

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
  factory AuthState.authenticated(User user) => AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() => const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.error(String message) => AuthState(status: AuthStatus.error, errorMessage: message);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(AuthState.initial());

  Future<void> login(String email, String password) async {
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

      _ref.read(tokenProvider.notifier).state = accessToken;

      final userResponse = await dio.get('/users/me');
      final userData = userResponse.data as Map<String, dynamic>;

      final user = User.fromBackendJson(userData, token: accessToken);
      state = AuthState.authenticated(user);
    } on DioException catch (e) {
      state = AuthState.error(e.message ?? 'Login failed');
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> loginAsTrainer(String email, String password) async {
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

      _ref.read(tokenProvider.notifier).state = accessToken;

      final userResponse = await dio.get('/users/me');
      final userData = userResponse.data as Map<String, dynamic>;

      final user = User.fromBackendJson(userData, token: accessToken);

      if (user.role != UserRole.trainer) {
        _ref.read(tokenProvider.notifier).state = null;
        state = AuthState.error('Access denied. You are not registered as a Trainer.');
        return;
      }

      state = AuthState.authenticated(user);
    } on DioException catch (e) {
      state = AuthState.error(e.message ?? 'Login failed');
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> loginAsGymOwner(String email, String password) async {
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

      _ref.read(tokenProvider.notifier).state = accessToken;

      final userResponse = await dio.get('/users/me');
      final userData = userResponse.data as Map<String, dynamic>;

      final user = User.fromBackendJson(userData, token: accessToken);

      if (user.role != UserRole.gymOwner) {
        _ref.read(tokenProvider.notifier).state = null;
        state = AuthState.error('Access denied. You are not registered as a Gym Owner.');
        return;
      }

      state = AuthState.authenticated(user);
    } on DioException catch (e) {
      state = AuthState.error(e.message ?? 'Login failed');
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> register(String firstName, String lastName, String email, String password) async {
    state = AuthState.loading();
    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
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

      _ref.read(tokenProvider.notifier).state = accessToken;

      final userResponse = await dio.get('/users/me');
      final userData = userResponse.data as Map<String, dynamic>;

      final user = User.fromBackendJson(userData, token: accessToken);
      state = AuthState.authenticated(user);
    } on DioException catch (e) {
      state = AuthState.error(e.message ?? 'Registration failed');
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  void logout() {
    _ref.read(tokenProvider.notifier).state = null;
    state = AuthState.unauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
