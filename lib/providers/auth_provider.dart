import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final user = User(
      id: 'mock-client-id',
      email: email.trim().isEmpty ? 'user@fitforge.com' : email.trim(),
      name: 'Guest User',
      role: UserRole.client,
      token: 'mock-jwt-token',
    );
    state = AuthState.authenticated(user);
  }

  Future<void> loginAsTrainer(String email, String password) async {
    state = AuthState.loading();
    final user = User(
      id: 'mock-trainer-id',
      email: email.trim().isEmpty ? 'trainer@fitforge.com' : email.trim(),
      name: 'Coach Alex',
      role: UserRole.trainer,
      token: 'mock-jwt-token',
    );
    state = AuthState.authenticated(user);
  }

  Future<void> loginAsGymOwner(String email, String password) async {
    state = AuthState.loading();
    final user = User(
      id: 'mock-owner-id',
      email: email.trim().isEmpty ? 'owner@fitforge.com' : email.trim(),
      name: 'Gym Owner',
      role: UserRole.gymOwner,
      token: 'mock-jwt-token',
    );
    state = AuthState.authenticated(user);
  }

  Future<void> register(String firstName, String lastName, String email, String password) async {
    state = AuthState.loading();
    final fullName = '$firstName $lastName'.trim();
    final user = User(
      id: 'mock-newuser-id',
      email: email.trim().isEmpty ? 'newuser@fitforge.com' : email.trim(),
      name: fullName.isEmpty ? 'New User' : fullName,
      role: UserRole.client,
      token: 'mock-jwt-token',
    );
    state = AuthState.authenticated(user);
  }

  void logout() {
    _ref.read(tokenProvider.notifier).state = null;
    state = AuthState.unauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
