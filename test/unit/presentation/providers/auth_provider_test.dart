import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_master/core/error/failures.dart';
import 'package:geo_master/domain/entities/user.dart';
import 'package:geo_master/presentation/providers/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;
  late StreamController<User?> authStreamController;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authStreamController = StreamController<User?>.broadcast();
  });

  tearDown(() {
    container.dispose();
    authStreamController.close();
  });

  User createTestUser({
    String id = TestData.testUserId,
    String? email = TestData.testEmail,
    String? displayName = TestData.testDisplayName,
    bool isAnonymous = false,
  }) {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      isAnonymous: isAnonymous,
      createdAt: DateTime.now(),
    );
  }

  group('AuthStateNotifier', () {
    group('initialization via authStateChanges stream', () {
      test('sets state to authenticated when user is emitted', () async {
        // Arrange
        final testUser = createTestUser();
        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);

        container = createTestContainer(authRepo: mockAuthRepository);

        // Read the provider to trigger initialization
        container.read(authStateProvider);

        // Act - emit a user through the stream
        authStreamController.add(testUser);

        // Allow stream listener to process
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Assert
        final state = container.read(authStateProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isA<AuthAuthenticated>());
        expect((state.value as AuthAuthenticated).user.id, equals(TestData.testUserId));
      });

      test('sets state to unauthenticated when null is emitted', () async {
        // Arrange
        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);

        container = createTestContainer(authRepo: mockAuthRepository);

        // Read the provider to trigger initialization
        container.read(authStateProvider);

        // Act - emit null through the stream
        authStreamController.add(null);

        // Allow stream listener to process
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Assert
        final state = container.read(authStateProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isA<AuthUnauthenticated>());
      });
    });

    group('signInAnonymously', () {
      test('successfully signs in anonymously', () async {
        // Arrange
        final anonymousUser = createTestUser(
          id: 'anon-123',
          email: null,
          displayName: null,
          isAnonymous: true,
        );
        when(() => mockAuthRepository.signInAnonymously())
            .thenAnswer((_) async => Right(anonymousUser));
        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);

        container = createTestContainer(authRepo: mockAuthRepository);

        // Act
        await container.read(authStateProvider.notifier).signInAnonymously();

        // Simulate auth stream emitting the user after successful sign-in
        authStreamController.add(anonymousUser);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Assert
        final state = container.read(authStateProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isA<AuthAuthenticated>());
        expect((state.value as AuthAuthenticated).user.isAnonymous, isTrue);
      });

      test('sets error state when sign in fails', () async {
        // Arrange
        when(() => mockAuthRepository.signInAnonymously())
            .thenAnswer((_) async => const Left(AuthFailure(message: 'Sign in failed')));
        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);

        container = createTestContainer(authRepo: mockAuthRepository);

        // Act
        await container.read(authStateProvider.notifier).signInAnonymously();

        // Assert
        final state = container.read(authStateProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isA<AuthError>());
      });
    });

    group('signOut', () {
      test('successfully signs out user', () async {
        // Arrange
        final testUser = createTestUser();
        when(() => mockAuthRepository.signOut())
            .thenAnswer((_) async => const Right(null));
        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);

        container = createTestContainer(authRepo: mockAuthRepository);

        // First authenticate
        authStreamController.add(testUser);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Act
        await container.read(authStateProvider.notifier).signOut();

        // Simulate auth stream emitting null after sign-out
        authStreamController.add(null);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Assert
        final state = container.read(authStateProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isA<AuthUnauthenticated>());
      });
    });
  });

  group('Derived Providers', () {
    test('currentUserProvider returns user when authenticated', () async {
      // Arrange
      final testUser = createTestUser();
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);

      container = createTestContainer(authRepo: mockAuthRepository);

      // Read provider to trigger initialization
      container.read(authStateProvider);

      // Trigger auth state
      authStreamController.add(testUser);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Assert
      final user = container.read(currentUserProvider);
      expect(user, isNotNull);
      expect(user!.id, equals(TestData.testUserId));
    });

    test('currentUserProvider returns null when unauthenticated', () async {
      // Arrange
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);

      container = createTestContainer(authRepo: mockAuthRepository);

      // Read provider to trigger initialization
      container.read(authStateProvider);

      // Trigger unauthenticated state
      authStreamController.add(null);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Assert
      final user = container.read(currentUserProvider);
      expect(user, isNull);
    });

    test('isAuthenticatedProvider returns correct value', () async {
      // Arrange
      final testUser = createTestUser();
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);

      container = createTestContainer(authRepo: mockAuthRepository);

      // Read provider to trigger initialization
      container.read(authStateProvider);

      // Trigger authenticated state
      authStreamController.add(testUser);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(container.read(isAuthenticatedProvider), isTrue);
    });
  });
}
