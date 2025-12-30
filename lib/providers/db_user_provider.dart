import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

// Store, Fetch, Update user data in Firestore
class DbUserProvider extends ChangeNotifier {
  // Instance of Firestore
  final _db = FirebaseFirestore.instance;

  UserModel? _userCurrent; // Currently logged-in user
  // Allow read access, it is a function (defined by get) that returns _userCurrent:
  UserModel? get userCurrent => _userCurrent;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 1. CREATE USER (Call this after SignUp)

  // 1. CREATE USER (Call this after SignUp)
  Future<void> saveNewUser(UserModel userCurrent) async {
    try {
      _isLoading = true; // Start loading state
      notifyListeners(); // Notify listeners about state change

      // We use the Auth ID (uid) as the Document ID
      await _db
          .collection("users")
          .doc(userCurrent.id)
          .set(userCurrent.toJson());

      _userCurrent = userCurrent; // Save locally
    } catch (e) {
      debugPrint("Error saving user: $e");
    } finally {
      // Always executed, even if there was an error
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. GET USER (Call this in MainScreen)
  Future<void> getUserData(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      DocumentSnapshot<Map<String, dynamic>> snapshot = await _db
          .collection("users")
          .doc(uid)
          .get();

      if (snapshot.exists) {
        // Convert JSON to UserModel using your code
        _userCurrent = UserModel.fromSnapshot(snapshot);
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
