import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload image and return download URL
  Future<String> uploadMealImage(File imageFile, String userId) async {
    try {
      // Create unique filename
      final fileName = 'meal_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Create reference
      final storageRef = _storage
          .ref()
          .child('meals')
          .child(userId)
          .child(fileName);

      // Upload file
      await storageRef.putFile(imageFile);

      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }
}