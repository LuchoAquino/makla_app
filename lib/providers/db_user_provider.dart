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

  // 3. UPDATE USER DATA
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_userCurrent == null) throw "No user logged in";

      // 1. Update Firestore
      await _db.collection("users").doc(_userCurrent!.id).update(data);

      // 2. Update local copy (Memory)
      _userCurrent = _userCurrent!.copyWith(
        // Use the data from the map or keep the current value if it's null
        weight: data.containsKey('weight')
            ? data['weight']
            : _userCurrent!.weight,
        height: data.containsKey('height')
            ? data['height']
            : _userCurrent!.height,
        gender: data['gender'] ?? _userCurrent!.gender,
        goal: data['goal'] ?? _userCurrent!.goal,
        dateOfBirth: data['dateOfBirth'] ?? _userCurrent!.dateOfBirth,
        purposes: data['purposes'] ?? _userCurrent!.purposes,
        restrictions: data['restrictions'] ?? _userCurrent!.restrictions,
        diseases: data['diseases'] ?? _userCurrent!.diseases,
      );
    } catch (e) {
      debugPrint("Error updating user: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
