class UserModel {
  String uid;
  String? name;
  String? email;
  DateTime? dateOfBirth;
  String? gender;
  double? height;
  double? weight;
  List<String>? purposes;
  List<String>? allergies;
  List<String>? diseases;
  String? healthGoal;
  List<String>? dietaryPreferences;
  List<String>? religiousRestrictions;

  UserModel({
    required this.uid,
    this.name,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.height,
    this.weight,
    this.purposes,
    this.allergies,
    this.diseases,
    this.healthGoal,
    this.dietaryPreferences,
    this.religiousRestrictions,
  });

  // Factory constructor for creating a new UserModel instance from a map
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      name: data['name'],
      email: data['email'],
      dateOfBirth: data['dateOfBirth']?.toDate(),
      gender: data['gender'],
      height: data['height']?.toDouble(),
      weight: data['weight']?.toDouble(),
      purposes: List<String>.from(data['purposes'] ?? []),
      allergies: List<String>.from(data['allergies'] ?? []),
      diseases: List<String>.from(data['diseases'] ?? []),
      healthGoal: data['healthGoal'],
      dietaryPreferences: List<String>.from(data['dietaryPreferences'] ?? []),
      religiousRestrictions: List<String>.from(
        data['religiousRestrictions'] ?? [],
      ),
    );
  }

  // Method to convert a UserModel instance to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'height': height,
      'weight': weight,
      'purposes': purposes,
      'allergies': allergies,
      'diseases': diseases,
      'healthGoal': healthGoal,
      'dietaryPreferences': dietaryPreferences,
      'religiousRestrictions': religiousRestrictions,
    };
  }
}
