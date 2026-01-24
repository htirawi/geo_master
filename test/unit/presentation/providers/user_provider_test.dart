import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:geo_master/core/error/failures.dart';
import 'package:geo_master/domain/entities/user.dart';
import 'package:geo_master/domain/repositories/i_user_repository.dart';
import 'package:geo_master/presentation/providers/auth_provider.dart';
import 'package:geo_master/presentation/providers/user_provider.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  late MockUserRepository mockUserRepository;
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;
  late StreamController<User?> authStreamController;

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockAuthRepository = MockAuthRepository();
    authStreamController = StreamController<User?>.broadcast();
  });

  tearDown(() {
    container.dispose();
    authStreamController.close();
  });

  User createTestUser({
    UserProgress? progress,
  }) {
    return User(
      id: TestData.testUserId,
      email: TestData.testEmail,
      displayName: TestData.testDisplayName,
      createdAt: DateTime.now(),
      progress: progress ?? const UserProgress(),
    );
  }

  group('UserProfileNotifier', () {
    group('loadProfile', () {
      test('successfully loads user profile', () async {
        // Arrange
        final testUser = createTestUser(
          progress: const UserProgress(
            totalXp: 1000,
            level: 5,
            currentStreak: 7,
          ),
        );

        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);
        when(() => mockUserRepository.getCurrentUserData())
            .thenAnswer((_) async => Right(testUser));

        container = createTestContainer(
          userRepo: mockUserRepository,
          authRepo: mockAuthRepository,
        );

        // Act
        await container.read(userProfileProvider.notifier).loadProfile();

        // Assert
        final state = container.read(userProfileProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isA<UserProfileLoaded>());

        final loadedState = state.value as UserProfileLoaded;
        expect(loadedState.user.id, equals(TestData.testUserId));
        expect(loadedState.user.progress.totalXp, equals(1000));
        expect(loadedState.user.progress.level, equals(5));
      });

      test('sets error state when loading fails', () async {
        // Arrange
        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);
        when(() => mockUserRepository.getCurrentUserData())
            .thenAnswer((_) async => const Left(ServerFailure(message: 'User not found')));

        container = createTestContainer(
          userRepo: mockUserRepository,
          authRepo: mockAuthRepository,
        );

        // Act
        await container.read(userProfileProvider.notifier).loadProfile();

        // Assert
        final state = container.read(userProfileProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isA<UserProfileError>());
      });
    });

    group('addXp', () {
      test('successfully updates user XP', () async {
        // Arrange
        final testUser = createTestUser(
          progress: const UserProgress(totalXp: 1000),
        );
        final updatedProgress = const UserProgress(totalXp: 1100);

        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);
        when(() => mockUserRepository.getCurrentUserData())
            .thenAnswer((_) async => Right(testUser));
        when(() => mockUserRepository.addXp(TestData.testUserId, 100))
            .thenAnswer((_) async => Right(updatedProgress));

        container = createTestContainer(
          userRepo: mockUserRepository,
          authRepo: mockAuthRepository,
        );

        // Load profile first
        await container.read(userProfileProvider.notifier).loadProfile();

        // Act
        final result = await container.read(userProfileProvider.notifier).addXp(100);

        // Assert
        verify(() => mockUserRepository.addXp(TestData.testUserId, 100)).called(1);
        expect(result, isNotNull);
        expect(result!.totalXp, equals(1100));
      });

      test('returns null when no user is loaded', () async {
        // Arrange
        when(() => mockAuthRepository.authStateChanges)
            .thenAnswer((_) => authStreamController.stream);

        container = createTestContainer(
          userRepo: mockUserRepository,
          authRepo: mockAuthRepository,
        );

        // Don't load profile - state is initial

        // Act
        final result = await container.read(userProfileProvider.notifier).addXp(100);

        // Assert
        expect(result, isNull);
        verifyNever(() => mockUserRepository.addXp(any(), any()));
      });
    });
  });

  group('Leaderboard Provider', () {
    test('returns leaderboard entries', () async {
      // Arrange
      final entries = [
        const LeaderboardEntry(
          oduserId: 'user-1',
          displayName: 'Top Player',
          photoUrl: null,
          totalXp: 10000,
          level: 50,
          rank: 1,
          countriesLearned: 195,
        ),
        const LeaderboardEntry(
          oduserId: 'user-2',
          displayName: 'Second Player',
          photoUrl: null,
          totalXp: 8000,
          level: 40,
          rank: 2,
          countriesLearned: 150,
        ),
      ];

      when(() => mockUserRepository.getLeaderboard(type: LeaderboardType.weekly))
          .thenAnswer((_) async => Right(entries));
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);

      container = createTestContainer(
        userRepo: mockUserRepository,
        authRepo: mockAuthRepository,
      );

      // Act
      final result = await container.read(leaderboardProvider(LeaderboardType.weekly).future);

      // Assert
      expect(result.length, equals(2));
      expect(result.first.rank, equals(1));
      expect(result.first.displayName, equals('Top Player'));
    });

    test('returns empty list when leaderboard fails to load', () async {
      // Arrange
      when(() => mockUserRepository.getLeaderboard(type: LeaderboardType.weekly))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to load')));
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);

      container = createTestContainer(
        userRepo: mockUserRepository,
        authRepo: mockAuthRepository,
      );

      // Act
      final result = await container.read(leaderboardProvider(LeaderboardType.weekly).future);

      // Assert
      expect(result, isEmpty);
    });
  });

  group('User Rank Provider', () {
    test('returns user rank when authenticated', () async {
      // Arrange
      final testUser = createTestUser();

      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);
      when(() => mockUserRepository.getUserRank(TestData.testUserId))
          .thenAnswer((_) async => const Right(42));

      container = createTestContainer(
        userRepo: mockUserRepository,
        authRepo: mockAuthRepository,
      );

      // Read provider to trigger initialization
      container.read(authStateProvider);

      // Simulate authenticated user
      authStreamController.add(testUser);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Act
      final rank = await container.read(userRankProvider.future);

      // Assert
      expect(rank, equals(42));
    });

    test('returns 0 when user is not authenticated', () async {
      // Arrange
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);

      container = createTestContainer(
        userRepo: mockUserRepository,
        authRepo: mockAuthRepository,
      );

      // Read provider to trigger initialization
      container.read(authStateProvider);

      // Simulate unauthenticated state
      authStreamController.add(null);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Act
      final rank = await container.read(userRankProvider.future);

      // Assert
      expect(rank, equals(0));
    });
  });

  group('Derived Providers', () {
    test('userProgressProvider returns progress from profile', () async {
      // Arrange
      final testUser = createTestUser(
        progress: const UserProgress(
          totalXp: 5000,
          level: 10,
          currentStreak: 14,
        ),
      );

      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);
      when(() => mockUserRepository.getCurrentUserData())
          .thenAnswer((_) async => Right(testUser));

      container = createTestContainer(
        userRepo: mockUserRepository,
        authRepo: mockAuthRepository,
      );

      await container.read(userProfileProvider.notifier).loadProfile();

      // Assert
      final progress = container.read(userProgressProvider);
      expect(progress.totalXp, equals(5000));
      expect(progress.level, equals(10));
      expect(progress.currentStreak, equals(14));
    });

    test('userStreakProvider returns current streak', () async {
      // Arrange
      final testUser = createTestUser(
        progress: const UserProgress(currentStreak: 21),
      );

      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => authStreamController.stream);
      when(() => mockUserRepository.getCurrentUserData())
          .thenAnswer((_) async => Right(testUser));

      container = createTestContainer(
        userRepo: mockUserRepository,
        authRepo: mockAuthRepository,
      );

      await container.read(userProfileProvider.notifier).loadProfile();

      // Assert
      final streak = container.read(userStreakProvider);
      expect(streak, equals(21));
    });
  });
}
