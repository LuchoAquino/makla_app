import 'package:cloud_firestore/cloud_firestore.dart';
import 'nutrition_model.dart';

class MealModel {
  final String? id;
  final String dishName;
  final String description;
  final String imageUrl;
  final DateTime timestamp;
  final String mealType;
  final List<String> ingredients;
  final NutritionModel nutritionalInfo;
  final String confidence;

  MealModel({
    this.id,
    required this.dishName,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
    required this.mealType,
    required this.nutritionalInfo,
    required this.ingredients,
    required this.confidence,
  });

  // Convert to Firebase format (Write)
  Map<String, dynamic> toJson() {
    return {
      'dishName': dishName,
      'description': description,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'mealType': mealType,
      'ingredients': ingredients,
      'nutritionalInfo': nutritionalInfo.toJson(),
      'confidence': confidence,
    };
  }

  // Create from Firebase data (Read)
  factory MealModel.fromJson(Map<String, dynamic> json, String id) {
    return MealModel(
      id: id,
      dishName: json['dishName'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      mealType: json['mealType'] ?? 'Snack',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      nutritionalInfo: NutritionModel.fromJson(json['nutritionalInfo'] ?? {}),
      confidence: json['confidence'] ?? 'medium',
    );
  }

  // New factory to create MealModel from AI JSON response
  factory MealModel.fromAIJson(
    Map<String, dynamic> json,
    String localImagePath,
  ) {
    return MealModel(
      id: null, // Se generará al guardar en Firebase
      dishName: json['dishName'] ?? 'Unknown Food',
      description: json['description'] ?? 'No description available',
      imageUrl: localImagePath,
      timestamp: DateTime.now(),
      mealType: json['mealType'] ?? 'Snack',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      nutritionalInfo: NutritionModel.fromJson(json['nutritionalInfo'] ?? {}),
      confidence: json['confidence'] ?? 'low',
    );
  }

  // --- NEW METHOD: CopyWith ---
  // Allows us to create a new instance with updated fields (e.g., user changes mealType)
  MealModel copyWith({
    String? id,
    String? dishName,
    String? description,
    String? imageUrl,
    DateTime? timestamp,
    String? mealType,
    List<String>? ingredients,
    NutritionModel? nutritionalInfo,
    String? confidence,
  }) {
    return MealModel(
      id: id ?? this.id,
      dishName: dishName ?? this.dishName,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      mealType: mealType ?? this.mealType,
      ingredients: ingredients ?? this.ingredients,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      confidence: confidence ?? this.confidence,
    );
  }
}
