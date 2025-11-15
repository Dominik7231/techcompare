import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  late final GoogleSignIn _googleSignIn = kIsWeb
      ? GoogleSignIn(
          clientId: '425679233015-dlikrug7efuc002befhqcvr36h8423of.apps.googleusercontent.com',
        )
      : GoogleSignIn();

  bool get _isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Public flag that UI can check to decide whether to allow auth actions
  bool get isAvailable => _isFirebaseAvailable;

  FirebaseAuth? _getAuth() {
    if (!_isFirebaseAvailable) return null;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  // Get current user
  User? get currentUser => _getAuth()?.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges =>
      _getAuth()?.authStateChanges() ?? const Stream<User?>.empty();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = _getAuth();
    if (auth == null) {
      throw 'Firebase is not initialized on this platform.';
    }
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final auth = _getAuth();
    if (auth == null) {
      throw 'Firebase is not initialized on this platform.';
    }
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    final auth = _getAuth();
    if (auth == null) {
      throw 'Firebase is not initialized on this platform.';
    }
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    final auth = _getAuth();
    if (auth == null) {
      // Still sign out Google if available
      await _googleSignIn.signOut();
      return;
    }
    await Future.wait([
      auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _getAuth();
    if (auth == null) {
      throw 'Firebase is not initialized on this platform.';
    }
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update user display name
  Future<void> updateDisplayName(String displayName) async {
    final auth = _getAuth();
    if (auth == null) {
      throw 'Firebase is not initialized on this platform.';
    }
    try {
      await auth.currentUser?.updateDisplayName(displayName);
      await auth.currentUser?.reload();
    } catch (e) {
      throw 'Failed to update display name: $e';
    }
  }

  // Update user email
  Future<void> updateEmail(String newEmail) async {
    final auth = _getAuth();
    if (auth == null) {
      throw 'Firebase is not initialized on this platform.';
    }
    try {
      await auth.currentUser?.updateEmail(newEmail);
      await auth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update user password
  Future<void> updatePassword(String newPassword) async {
    final auth = _getAuth();
    if (auth == null) {
      throw 'Firebase is not initialized on this platform.';
    }
    try {
      await auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    final auth = _getAuth();
    if (auth == null) {
      throw 'Firebase is not initialized on this platform.';
    }
    try {
      await auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}

