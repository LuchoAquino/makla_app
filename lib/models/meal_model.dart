import 'package:cloud_firestore/cloud_firestore.dart';
import 'nutrition_model.dart';

class MealModel {
  final String? id;
  final String dishName;
  final String description;
  final String imageUrl;
  final DateTime timestamp;
  final String mealType;
  final NutritionModel nutritionalInfo;
  final List<String> ingredients;

  MealModel({
    this.id,
    required this.dishName,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
    required this.mealType,
    required this.nutritionalInfo,
    required this.ingredients,
  });

  // Convert to Firebase format
  Map<String, dynamic> toJson() {
    return {
      'dishName': dishName,
      'description': description,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'mealType': mealType,
      'nutritionalInfo': nutritionalInfo.toJson(),
      'ingredients': ingredients,
    };
  }

  // Create from Firebase data
  factory MealModel.fromJson(Map<String, dynamic> json, String id) {
    return MealModel(
      id: id,
      dishName: json['dishName'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      mealType: json['mealType'] ?? 'other',
      nutritionalInfo: NutritionModel.fromJson(json['nutritionalInfo'] ?? {}),
      ingredients: List<String>.from(json['ingredients'] ?? []),
    );
  }
}
