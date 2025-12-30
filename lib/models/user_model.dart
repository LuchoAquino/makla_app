import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime dateOfBirth;
  final double weight;
  final double height;
  final String gender;
  final String goal;
  final String checkInFrequency;
  final DateTime? createdAt;

  final List<String> purposes;
  final List<String> restrictions;
  final List<String> diseases;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.dateOfBirth,
    required this.weight,
    required this.height,
    required this.gender,
    required this.goal,
    required this.checkInFrequency,
    this.purposes = const [],
    this.restrictions = const [],
    this.diseases = const [],
    this.createdAt,
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    // Exception for birthdate not yet reached this year
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Convert UserModel to JSON for Firebase (from the App to Firebase (Store/update))
  Map<String, dynamic> toJson() {
    // Firebase understands Map<String, dynamic>
    return {
      'name': name,
      'email': email,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'weight': weight,
      'height': height,
      'gender': gender,
      'goal': goal,
      'checkInFrequency': checkInFrequency,
      'purposes': purposes,
      'restrictions': restrictions,
      'diseases': diseases,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // Create UserModel from Firebase JSON (from Firebase to the App)
  factory UserModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data()!;
    return UserModel(
      id: document.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      weight: (data['weight'] ?? 0).toDouble(),
      height: (data['height'] ?? 0).toDouble(),
      gender: data['gender'] ?? '',
      goal: data['goal'] ?? '',
      checkInFrequency: data['checkInFrequency'] ?? '',
      purposes: List<String>.from(data['purposes'] ?? []),
      restrictions: List<String>.from(data['restrictions'] ?? []),
      diseases: List<String>.from(data['diseases'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? dateOfBirth,
    double? weight,
    double? height,
    String? gender,
    String? goal,
    String? checkInFrequency,
    List<String>? purposes,
    List<String>? restrictions,
    List<String>? diseases,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      checkInFrequency: checkInFrequency ?? this.checkInFrequency,
      purposes: purposes ?? this.purposes,
      restrictions: restrictions ?? this.restrictions,
      diseases: diseases ?? this.diseases,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
