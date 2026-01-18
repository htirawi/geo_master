import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/remote/firebase_auth_datasource.dart';

/// Auth repository implementation
class AuthRepositoryImpl implements IAuthRepository {
  /// Creates an instance of [AuthRepositoryImpl]
  AuthRepositoryImpl(this._authDataSource);

  final IFirebaseAuthDataSource _authDataSource;

  @override
  Stream<User?> get authStateChanges => _authDataSource.authStateChanges;

  @override
  User? get currentUser => _authDataSource.currentUser;

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final user = await _authDataSource.signInWithGoogle();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return const Left(AuthFailure(
        message: 'An unexpected error occurred during sign in.',
        code: 'unknown',
      ));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      final user = await _authDataSource.signInWithApple();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return const Left(AuthFailure(
        message: 'An unexpected error occurred during sign in.',
        code: 'unknown',
      ));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return const Left(AuthFailure(
        message: 'An unexpected error occurred during sign in.',
        code: 'unknown',
      ));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final user = await _authDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return const Left(AuthFailure(
        message: 'An unexpected error occurred during sign up.',
        code: 'unknown',
      ));
    }
  }

  @override
  Future<Either<Failure, User>> signInAnonymously() async {
    try {
      final user = await _authDataSource.signInAnonymously();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return const Left(AuthFailure(
        message: 'An unexpected error occurred during sign in.',
        code: 'unknown',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _authDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return const Left(AuthFailure(
        message: 'An unexpected error occurred during sign out.',
        code: 'unknown',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _authDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return const Left(AuthFailure(
        message: 'An unexpected error occurred while sending reset email.',
        code: 'unknown',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await _authDataSource.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return const Left(AuthFailure(
        message: 'An unexpected error occurred while updating profile.',
        code: 'unknown',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _authDataSource.deleteAccount();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return const Left(AuthFailure(
        message: 'An unexpected error occurred while deleting account.',
        code: 'unknown',
      ));
    }
  }
}
