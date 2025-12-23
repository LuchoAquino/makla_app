import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final int age;
  final double weight;
  final double height;
  final String gender;
  final String goal;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.goal,
    this.createdAt,
  });

  // Convert UserModel to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'goal': goal,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
    };
  }

  // Create UserModel from Firebase JSON
  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 0,
      weight: (json['weight'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      gender: json['gender'] ?? '',
      goal: json['goal'] ?? '',
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? goal,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}