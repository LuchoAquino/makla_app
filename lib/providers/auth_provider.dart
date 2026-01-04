import 'package:firebase_auth/firebase_auth.dart'; // Access to FirebaseAuth, User and UserCredential
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Global Variable
// Class -> AuthService, ValueNotifier -> Object and 'authService' Notified when this value changes
ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

// Service layer between the App and Firebase
class AuthService {
  // Instance of Firebase for all the app
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // Current User if it is null -> nobody is logged
  User? get currentUser => firebaseAuth.currentUser;

  // Changes in the authentication -> login, logout, expired session
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  // -------------- Login Mail ----------------
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      // Verification
      email: email,
      password: password,
    );
  }

  // -------------- SignUp Mail ----------------
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // -------------- Logout Mail ----------------
  Future<void> signOut() async {
    // 1. Attempt to sign out of Google (so it forgets the selected account)
    // We use try-catch in case an internal error occurs in the plugin,
    // so it doesn't stop the Firebase logout.
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint("Error signing out of Google: $e");
    }

    // 2. Sign out of Firebase (this is what actually logs the user out of the app)
    await firebaseAuth.signOut();
  }

  // ---------------- Google Sign In ----------------
  Future<UserCredential> signInWithGoogle() async {
    // Create GoogleSignIn instance
    final GoogleSignIn googleSignIn = GoogleSignIn();

    // Start Google Sign-In flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // If the user cancels the login
    if (googleUser == null) {
      throw Exception('Google sign in aborted by user');
    }

    // Get authentication tokens from Google
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create Firebase credential from Google tokens
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with Google credential
    return await firebaseAuth.signInWithCredential(credential);
  }
}
