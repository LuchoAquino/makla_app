import 'package:firebase_auth/firebase_auth.dart'; // Access to FirebaseAuth, User and UserCredential
import 'package:flutter/foundation.dart';

// Global Variable
// Class -> AuthService, ValueNotifier -> Object and 'authService' Notified when this value changes
ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

// Layer between my App and Firebase
class AuthService {
  // Instance of Firebase for all the app
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // Current User if it is null -> nobody is logged
  User? get currentUser => firebaseAuth.currentUser;

  // Changes in the authentication -> login, logout, expired session
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  // -------------- Login ----------------
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

  // -------------- SignUp ----------------
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // -------------- Logout ----------------
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}
