import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_model.dart';
import '../models/nutrition_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save meal to Firestore
  Future<String> saveMeal(String userId, MealModel meal) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meals')
          .add(meal.toJson());

      // Update daily stats
      await _updateDailyStats(userId, meal.nutritionalInfo, meal.timestamp);

      return docRef.id;
    } catch (e) {
      print('Error saving meal: $e');
      rethrow;
    }
  }

  /// Update daily statistics
  Future<void> _updateDailyStats(
    String userId,
    NutritionModel nutrition,
    DateTime mealTime,
  ) async {
    try {
      // Format date as YYYY-MM-DD
      final dateStr = '${mealTime.year}-'
          '${mealTime.month.toString().padLeft(2, '0')}-'
          '${mealTime.day.toString().padLeft(2, '0')}';

      final statsRef = _firestore
          .collection('dailyStats')
          .doc(userId)
          .collection('dates')
          .doc(dateStr);

      // Use transaction to safely update
      await _firestore.runTransaction((transaction) async {
        final statsDoc = await transaction.get(statsRef);

        if (statsDoc.exists) {
          // Update existing stats
          final currentData = statsDoc.data()!;
          transaction.update(statsRef, {
            'totalCalories': (currentData['totalCalories'] ?? 0) + nutrition.calories,
            'totalProtein': (currentData['totalProtein'] ?? 0) + nutrition.protein,
            'totalCarbs': (currentData['totalCarbs'] ?? 0) + nutrition.carbs,
            'totalFat': (currentData['totalFat'] ?? 0) + nutrition.fat,
            'mealsCount': (currentData['mealsCount'] ?? 0) + 1,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          // Create new stats document
          transaction.set(statsRef, {
            'date': Timestamp.fromDate(mealTime),
            'totalCalories': nutrition.calories,
            'totalProtein': nutrition.protein,
            'totalCarbs': nutrition.carbs,
            'totalFat': nutrition.fat,
            'mealsCount': 1,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error updating daily stats: $e');
      rethrow;
    }
  }

  /// Get user's meals
  Stream<List<MealModel>> getUserMeals(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('meals')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MealModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Get daily stats for a specific date
  Future<Map<String, dynamic>?> getDailyStats(String userId, DateTime date) async {
    try {
      final dateStr = '${date.year}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection('dailyStats')
          .doc(userId)
          .collection('dates')
          .doc(dateStr)
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting daily stats: $e');
      return null;
    }
  }
}