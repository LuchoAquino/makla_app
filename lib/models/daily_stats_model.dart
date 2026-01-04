import 'package:cloud_firestore/cloud_firestore.dart';

class DailyStatsModel {
  final String userId;
  final String dateString; // Format: YYYY-MM-DD
  final DateTime date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int mealsCount;
  final DateTime? lastUpdated;

  DailyStatsModel({
    required this.userId,
    required this.dateString,
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.mealsCount,
    this.lastUpdated,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'date': Timestamp.fromDate(date),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'mealsCount': mealsCount,
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : FieldValue.serverTimestamp(),
    };
  }

  // Create from Firebase JSON
  factory DailyStatsModel.fromJson(
    Map<String, dynamic> json,
    String userId,
    String dateString,
  ) {
    return DailyStatsModel(
      userId: userId,
      dateString: dateString,
      date: (json['date'] as Timestamp).toDate(),
      totalCalories: (json['totalCalories'] ?? 0).toDouble(),
      totalProtein: (json['totalProtein'] ?? 0).toDouble(),
      totalCarbs: (json['totalCarbs'] ?? 0).toDouble(),
      totalFat: (json['totalFat'] ?? 0).toDouble(),
      mealsCount: json['mealsCount'] ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? (json['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  // Helper: Format DateTime to YYYY-MM-DD
  static String formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // Create empty stats for a new day
  factory DailyStatsModel.empty(String userId, DateTime date) {
    return DailyStatsModel(
      userId: userId,
      dateString: formatDate(date),
      date: date,
      totalCalories: 0,
      totalProtein: 0,
      totalCarbs: 0,
      totalFat: 0,
      mealsCount: 0,
      lastUpdated: DateTime.now(),
    );
  }

  // Create updated stats after adding a meal
  DailyStatsModel addMeal(
    double calories,
    double protein,
    double carbs,
    double fat,
  ) {
    return DailyStatsModel(
      userId: userId,
      dateString: dateString,
      date: date,
      totalCalories: totalCalories + calories,
      totalProtein: totalProtein + protein,
      totalCarbs: totalCarbs + carbs,
      totalFat: totalFat + fat,
      mealsCount: mealsCount + 1,
      lastUpdated: DateTime.now(),
    );
  }
}
