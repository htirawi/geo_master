# GeoMaster Architecture

This document describes the architectural patterns and conventions used in the GeoMaster Flutter application.

## Table of Contents

1. [Project Structure](#project-structure)
2. [Domain Layer](#domain-layer)
3. [Dependency Injection](#dependency-injection)
4. [State Management](#state-management)
5. [Testing](#testing)

---

## Project Structure

```
lib/
├── app/                    # Application configuration
│   └── di/                 # Dependency injection
│       ├── service_locator.dart      # GetIt registration
│       └── repository_providers.dart # Riverpod bridge providers
├── core/                   # Shared utilities
│   ├── error/              # Failure types
│   ├── network/            # API client
│   └── services/           # Core services
├── data/                   # Data layer
│   ├── datasources/        # Local and remote data sources
│   ├── models/             # Data transfer objects
│   └── repositories/       # Repository implementations
├── domain/                 # Business logic (centralized)
│   ├── entities/           # Domain models
│   └── repositories/       # Repository interfaces
├── features/               # Feature-specific UI
│   └── [feature]/
│       └── presentation/   # Screens and widgets
└── presentation/           # Shared presentation layer
    └── providers/          # Riverpod state management
```

### Centralized Domain Layer

GeoMaster uses a **centralized domain layer** rather than feature-scoped domain directories:

- **Entities** live in `lib/domain/entities/` - shared across all features
- **Repository interfaces** live in `lib/domain/repositories/` - contracts for data access
- **Features** contain only presentation code (screens, widgets)

This approach avoids duplication and makes cross-feature data sharing straightforward.

---

## Domain Layer

### Entities

Domain entities are immutable data classes that represent core business concepts:

```dart
// lib/domain/entities/user.dart
class User {
  final String id;
  final String? email;
  final String? displayName;
  final bool isAnonymous;
  final DateTime createdAt;
  final UserProgress progress;

  const User({
    required this.id,
    this.email,
    this.displayName,
    this.isAnonymous = false,
    required this.createdAt,
    this.progress = const UserProgress(),
  });
}
```

### Repository Interfaces

Repository interfaces define data access contracts:

```dart
// lib/domain/repositories/i_auth_repository.dart
abstract class IAuthRepository {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<Either<Failure, User>> signInAnonymously();
  Future<Either<Failure, void>> signOut();
}
```

Key conventions:
- Interface names start with `I` prefix
- Methods return `Either<Failure, T>` for error handling
- Streams for reactive data (`authStateChanges`)
- Sync getters for cached data (`currentUser`)

---

## Dependency Injection

GeoMaster uses a **hybrid DI pattern** that bridges GetIt (runtime) with Riverpod (testability).

### Registration (GetIt)

Services and repositories are registered in `lib/app/di/service_locator.dart`:

```dart
final GetIt sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Register datasources
  sl.registerLazySingleton<IAuthDataSource>(() => FirebaseAuthDataSource());

  // Register repositories
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(sl<IAuthDataSource>()),
  );
}
```

### Bridge Providers (Riverpod)

Repository providers in `lib/app/di/repository_providers.dart` bridge GetIt to Riverpod:

```dart
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return sl<IAuthRepository>();
});

final userRepositoryProvider = Provider<IUserRepository>((ref) {
  return sl<IUserRepository>();
});
```

### Usage in Providers

State providers use Riverpod's `ref.watch` to access repositories:

```dart
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<AuthState>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(authRepository);
});
```

### Testing with Overrides

The bridge pattern enables easy testing via Riverpod overrides:

```dart
final container = ProviderContainer(
  overrides: [
    authRepositoryProvider.overrideWithValue(mockAuthRepository),
    userRepositoryProvider.overrideWithValue(mockUserRepository),
  ],
);
```

---

## State Management

### Riverpod Providers

GeoMaster uses Riverpod for state management with these patterns:

#### StateNotifierProvider with AsyncValue

For complex state with loading/error handling:

```dart
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<AuthState>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(authRepository);
});
```

#### FutureProvider

For async data that doesn't need complex state:

```dart
final quizStatisticsProvider = FutureProvider<QuizStatistics>((ref) async {
  final quizRepository = ref.watch(quizRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return const QuizStatistics.empty();

  final result = await quizRepository.getQuizStatistics(user.id);
  return result.fold(
    (failure) => const QuizStatistics.empty(),
    (stats) => stats,
  );
});
```

#### Derived Providers

For computed values from other providers:

```dart
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.isAuthenticated ?? false;
});
```

### Sealed Classes for State

State is modeled using sealed classes for exhaustive pattern matching:

```dart
sealed class AuthState {
  const AuthState();

  bool get isAuthenticated => switch (this) {
    AuthAuthenticated() => true,
    _ => false,
  };

  User? get user => switch (this) {
    AuthAuthenticated(:final user) => user,
    _ => null,
  };
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
```

Benefits:
- Compiler enforces handling all cases
- Pattern matching with destructuring
- Computed properties on base class

---

## Testing

### Test Structure

```
test/
├── helpers/
│   └── test_helpers.dart    # Mock classes and utilities
└── unit/
    └── presentation/
        └── providers/       # Provider unit tests
```

### Mock Classes

Mocks are defined in `test/helpers/test_helpers.dart`:

```dart
class MockAuthRepository extends Mock implements IAuthRepository {}
class MockUserRepository extends Mock implements IUserRepository {}
class MockQuizRepository extends Mock implements IQuizRepository {}
```

### Test Container

Use `createTestContainer()` for provider testing:

```dart
ProviderContainer createTestContainer({
  IAuthRepository? authRepo,
  IUserRepository? userRepo,
  IQuizRepository? quizRepo,
}) {
  return ProviderContainer(
    overrides: [
      if (authRepo != null) authRepositoryProvider.overrideWithValue(authRepo),
      if (userRepo != null) userRepositoryProvider.overrideWithValue(userRepo),
      if (quizRepo != null) quizRepositoryProvider.overrideWithValue(quizRepo),
    ],
  );
}
```

### Testing Stream-Based Providers

For providers that depend on streams (like auth state):

```dart
test('sets state to authenticated when user is emitted', () async {
  // Arrange
  final authStreamController = StreamController<User?>.broadcast();
  when(() => mockAuthRepository.authStateChanges)
      .thenAnswer((_) => authStreamController.stream);

  container = createTestContainer(authRepo: mockAuthRepository);

  // Read provider to trigger initialization
  container.read(authStateProvider);

  // Emit user through stream
  authStreamController.add(testUser);
  await Future.delayed(const Duration(milliseconds: 50));

  // Assert
  final state = container.read(authStateProvider);
  expect(state.value, isA<AuthAuthenticated>());
});
```

### Mocktail Fallback Values

Register fallback values for enum types in `setUpAll`:

```dart
setUpAll(() {
  registerFallbackValue(QuizMode.capitals);
  registerFallbackValue(QuizDifficulty.medium);
});
```

---

## Error Handling

### Failure Types

Errors are modeled as sealed failure classes:

```dart
sealed class Failure {
  final String message;
  const Failure({required this.message});
}

final class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

final class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}
```

### Either Pattern

Repository methods return `Either<Failure, T>` using the dartz package:

```dart
Future<Either<Failure, User>> signInAnonymously() async {
  try {
    final user = await _authDataSource.signInAnonymously();
    return Right(user);
  } catch (e) {
    return Left(AuthFailure(message: e.toString()));
  }
}
```

Handling results:

```dart
final result = await repository.signInAnonymously();
result.fold(
  (failure) => state = AsyncValue.data(AuthError(failure.message)),
  (user) => state = AsyncValue.data(AuthAuthenticated(user)),
);
```

---

## Summary

| Pattern | Purpose |
|---------|---------|
| Centralized domain | Avoid duplication, enable cross-feature sharing |
| GetIt + Riverpod bridge | Runtime DI with test overrides |
| Sealed classes | Type-safe, exhaustive state handling |
| Either<Failure, T> | Functional error handling |
| AsyncValue | Loading/error state in UI |
| Stream-based auth | Reactive authentication state |
