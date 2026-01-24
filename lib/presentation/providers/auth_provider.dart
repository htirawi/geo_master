import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/repository_providers.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';

/// Auth state
sealed class AuthState {
  const AuthState();

  bool get isAuthenticated => this is AuthAuthenticated;
  bool get isLoading => this is AuthLoading;

  User? get user {
    if (this is AuthAuthenticated) {
      return (this as AuthAuthenticated).user;
    }
    return null;
  }
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  @override
  final User user;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.failure);

  final Failure failure;
}

/// Auth state notifier
class AuthStateNotifier extends StateNotifier<AsyncValue<AuthState>> {
  AuthStateNotifier(this._authRepository)
      : super(const AsyncValue.loading()) {
    _init();
  }

  final IAuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  void _init() {
    _authSubscription = _authRepository.authStateChanges.listen(
      (user) {
        if (user != null) {
          state = AsyncValue.data(AuthAuthenticated(user));
        } else {
          state = const AsyncValue.data(AuthUnauthenticated());
        }
      },
      onError: (Object error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
    );
  }

  /// Sign in with Google
  /// Note: Success state is handled by the auth stream listener to avoid race conditions.
  /// Only errors are handled manually here.
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signInWithGoogle();
    result.fold(
      (failure) => state = AsyncValue.data(AuthError(failure)),
      (_) {}, // Success handled by auth stream
    );
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signInWithApple();
    result.fold(
      (failure) => state = AsyncValue.data(AuthError(failure)),
      (_) {}, // Success handled by auth stream
    );
  }

  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    result.fold(
      (failure) => state = AsyncValue.data(AuthError(failure)),
      (_) {}, // Success handled by auth stream
    );
  }

  /// Sign up with email and password
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
    result.fold(
      (failure) => state = AsyncValue.data(AuthError(failure)),
      (_) {}, // Success handled by auth stream
    );
  }

  /// Sign in anonymously (guest mode)
  Future<void> signInAnonymously() async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signInAnonymously();
    result.fold(
      (failure) => state = AsyncValue.data(AuthError(failure)),
      (_) {}, // Success handled by auth stream
    );
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final result = await _authRepository.signOut();
    result.fold(
      (failure) => state = AsyncValue.data(AuthError(failure)),
      (_) {}, // Success handled by auth stream (will emit null user -> AuthUnauthenticated)
    );
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    final result = await _authRepository.sendPasswordResetEmail(email);
    return result.isRight();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Auth state provider
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<AuthState>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(authRepository);
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.user;
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.isAuthenticated ?? false;
});
