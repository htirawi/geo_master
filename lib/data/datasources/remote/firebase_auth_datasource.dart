import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/user.dart';

/// Firebase Auth data source interface
abstract class IFirebaseAuthDataSource {
  /// Stream of auth state changes
  Stream<User?> get authStateChanges;

  /// Get current user
  User? get currentUser;

  /// Sign in with Google
  Future<User> signInWithGoogle();

  /// Sign in with Apple
  Future<User> signInWithApple();

  /// Sign in with email and password
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign in anonymously
  Future<User> signInAnonymously();

  /// Sign out
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Delete account
  Future<void> deleteAccount();
}

/// Firebase Auth data source implementation
class FirebaseAuthDataSource implements IFirebaseAuthDataSource {
  FirebaseAuthDataSource({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  // Security: Rate limiting for password reset
  final Map<String, DateTime> _passwordResetAttempts = {};
  static const Duration _passwordResetCooldown = Duration(minutes: 2);

  // Security: Track anonymous sign-ins for rate limiting
  DateTime? _lastAnonymousSignIn;
  static const Duration _anonymousSignInCooldown = Duration(seconds: 30);

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return _mapFirebaseUser(firebaseUser);
    });
  }

  @override
  User? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return _mapFirebaseUser(firebaseUser);
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException(
          message: 'Google sign in was cancelled',
          code: 'sign_in_cancelled',
        );
      }

      // Obtain the auth details
      final googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw const AuthException(
          message: 'Failed to sign in with Google',
          code: 'sign_in_failed',
        );
      }

      return _mapFirebaseUser(firebaseUser);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      // Security: Don't expose internal error details
      throw const AuthException(
        message: 'An error occurred during Google sign in',
        code: 'unknown',
      );
    }
  }

  @override
  Future<User> signInWithApple() async {
    try {
      // Request Apple ID credentials
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential
      final oAuthCredential = fb.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final userCredential =
          await _firebaseAuth.signInWithCredential(oAuthCredential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw const AuthException(
          message: 'Failed to sign in with Apple',
          code: 'sign_in_failed',
        );
      }

      // Update display name if provided by Apple and not already set
      if (firebaseUser.displayName == null &&
          appleCredential.givenName != null) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty) {
          await firebaseUser.updateDisplayName(displayName);
          // Reload user to get updated profile data
          await firebaseUser.reload();
          final updatedUser = _firebaseAuth.currentUser;
          if (updatedUser != null) {
            return _mapFirebaseUser(updatedUser);
          }
        }
      }

      return _mapFirebaseUser(firebaseUser);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      throw AuthException(
        message: e.message,
        code: e.code.toString(),
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      // Security: Don't expose internal error details
      throw const AuthException(
        message: 'An error occurred during Apple sign in',
        code: 'unknown',
      );
    }
  }

  @override
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Validate inputs before making API call
    final emailValidation = Validators.validateEmail(email);
    if (!emailValidation.isValid) {
      throw AuthException(
        message: emailValidation.errorMessage!,
        code: 'invalid-email',
      );
    }

    final passwordValidation = Validators.validatePasswordForSignIn(password);
    if (!passwordValidation.isValid) {
      throw AuthException(
        message: passwordValidation.errorMessage!,
        code: 'invalid-password',
      );
    }

    try {
      final sanitizedEmail = Validators.sanitizeEmail(email);
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: sanitizedEmail,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw const AuthException(
          message: 'Failed to sign in',
          code: 'sign_in_failed',
        );
      }

      return _mapFirebaseUser(firebaseUser);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      // Security: Don't expose internal error details
      throw const AuthException(
        message: 'An error occurred during sign in',
        code: 'unknown',
      );
    }
  }

  @override
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // Validate inputs before making API call
    final emailValidation = Validators.validateEmail(email);
    if (!emailValidation.isValid) {
      throw AuthException(
        message: emailValidation.errorMessage!,
        code: 'invalid-email',
      );
    }

    final passwordValidation = Validators.validatePassword(password);
    if (!passwordValidation.isValid) {
      throw AuthException(
        message: passwordValidation.errorMessage!,
        code: 'weak-password',
      );
    }

    final nameValidation = Validators.validateDisplayName(displayName);
    if (!nameValidation.isValid) {
      throw AuthException(
        message: nameValidation.errorMessage!,
        code: 'invalid-name',
      );
    }

    try {
      final sanitizedEmail = Validators.sanitizeEmail(email);
      final sanitizedName = displayName != null
          ? Validators.sanitizeDisplayName(displayName)
          : null;

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: sanitizedEmail,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw const AuthException(
          message: 'Failed to create account',
          code: 'sign_up_failed',
        );
      }

      // Update display name if provided
      if (sanitizedName != null && sanitizedName.isNotEmpty) {
        await firebaseUser.updateDisplayName(sanitizedName);
        // Reload user to get updated profile data
        await firebaseUser.reload();
        final updatedUser = _firebaseAuth.currentUser;
        if (updatedUser != null) {
          return _mapFirebaseUser(updatedUser);
        }
      }

      return _mapFirebaseUser(firebaseUser);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      // Security: Don't expose internal error details
      throw const AuthException(
        message: 'An error occurred during sign up',
        code: 'unknown',
      );
    }
  }

  @override
  Future<User> signInAnonymously() async {
    // Security: Rate limit anonymous sign-ins to prevent abuse
    if (_lastAnonymousSignIn != null) {
      final elapsed = DateTime.now().difference(_lastAnonymousSignIn!);
      if (elapsed < _anonymousSignInCooldown) {
        throw const AuthException(
          message: 'Please wait before trying again',
          code: 'rate_limited',
        );
      }
    }

    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      _lastAnonymousSignIn = DateTime.now();

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw const AuthException(
          message: 'Failed to sign in anonymously',
          code: 'sign_in_failed',
        );
      }

      return _mapFirebaseUser(firebaseUser);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException(
        message: 'An error occurred during anonymous sign in',
        code: 'unknown',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _firebaseAuth.signOut();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      // Security: Don't expose internal error details
      throw const AuthException(
        message: 'An error occurred during sign out',
        code: 'unknown',
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Security: Rate limit password reset requests per email
    final normalizedEmail = email.trim().toLowerCase();
    final lastAttempt = _passwordResetAttempts[normalizedEmail];

    if (lastAttempt != null) {
      final elapsed = DateTime.now().difference(lastAttempt);
      if (elapsed < _passwordResetCooldown) {
        final remainingSeconds =
            (_passwordResetCooldown - elapsed).inSeconds;
        throw AuthException(
          message: 'Please wait $remainingSeconds seconds before requesting another reset',
          code: 'rate_limited',
        );
      }
    }

    // Security: Validate email format
    final emailValidation = Validators.validateEmail(email);
    if (!emailValidation.isValid) {
      throw AuthException(
        message: emailValidation.errorMessage!,
        code: 'invalid-email',
      );
    }

    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: Validators.sanitizeEmail(email),
      );
      // Record successful request for rate limiting
      _passwordResetAttempts[normalizedEmail] = DateTime.now();

      // Security: Clean up old entries to prevent memory leak
      _cleanupPasswordResetAttempts();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException(
        message: 'An error occurred while sending password reset email',
        code: 'unknown',
      );
    }
  }

  /// Clean up old password reset attempt records
  void _cleanupPasswordResetAttempts() {
    final now = DateTime.now();
    _passwordResetAttempts.removeWhere((_, timestamp) {
      return now.difference(timestamp) > const Duration(hours: 1);
    });
  }

  @override
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    // Validate inputs before making API call
    if (displayName != null) {
      final nameValidation = Validators.validateDisplayName(displayName);
      if (!nameValidation.isValid) {
        throw AuthException(
          message: nameValidation.errorMessage!,
          code: 'invalid-name',
        );
      }
    }

    if (photoUrl != null) {
      final urlValidation = Validators.validatePhotoUrl(photoUrl);
      if (!urlValidation.isValid) {
        throw AuthException(
          message: urlValidation.errorMessage!,
          code: 'invalid-photo-url',
        );
      }
    }

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(
          message: 'No user is currently signed in',
          code: 'user_not_found',
        );
      }

      if (displayName != null) {
        final sanitizedName = Validators.sanitizeDisplayName(displayName);
        await user.updateDisplayName(sanitizedName);
      }
      if (photoUrl != null) {
        // Only allow HTTPS URLs for photo
        await user.updatePhotoURL(photoUrl);
      }
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      // Security: Don't expose internal error details
      throw const AuthException(
        message: 'An error occurred while updating profile',
        code: 'unknown',
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(
          message: 'No user is currently signed in',
          code: 'user_not_found',
        );
      }
      await user.delete();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      // Security: Don't expose internal error details
      throw const AuthException(
        message: 'An error occurred while deleting account',
        code: 'unknown',
      );
    }
  }

  /// Map Firebase user to domain User entity
  User _mapFirebaseUser(fb.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      isAnonymous: firebaseUser.isAnonymous,
      isEmailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

  /// Get human-readable error message from Firebase error code
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'requires-recent-login':
        return 'Please sign in again to perform this action.';
      default:
        return 'An authentication error occurred.';
    }
  }
}
