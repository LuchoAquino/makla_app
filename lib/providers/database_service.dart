import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_model.dart';
import '../models/nutrition_model.dart';
import '../models/user_model.dart';
import '../models/daily_stats_model.dart';

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

  /// ================== USER METHODS ==================

  /// Create or update user profile
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving user: $e');
      rethrow;
    }
  }

  /// Get user profile by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      return doc.exists ? UserModel.fromJson(doc.data()!, userId) : null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Get user profile as stream for real-time updates
  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromJson(doc.data()!, userId) : null);
  }

  /// Update user profile fields
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update(updates);
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  /// Delete user and all their data
  Future<void> deleteUser(String userId) async {
    try {
      final batch = _firestore.batch();

      // Delete user meals
      final mealsQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meals')
          .get();
      
      for (var doc in mealsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user daily stats
      final statsQuery = await _firestore
          .collection('dailyStats')
          .doc(userId)
          .collection('dates')
          .get();
      
      for (var doc in statsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete dailyStats parent document
      batch.delete(_firestore.collection('dailyStats').doc(userId));

      // Delete user profile
      batch.delete(_firestore.collection('users').doc(userId));

      await batch.commit();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  /// ================== ENHANCED STATS METHODS ==================

  /// Get daily stats as DailyStatsModel
  Future<DailyStatsModel?> getDailyStatsModel(String userId, DateTime date) async {
    try {
      final dateStr = DailyStatsModel.formatDate(date);
      
      final doc = await _firestore
          .collection('dailyStats')
          .doc(userId)
          .collection('dates')
          .doc(dateStr)
          .get();

      return doc.exists 
          ? DailyStatsModel.fromJson(doc.data()!, userId, dateStr)
          : null;
    } catch (e) {
      print('Error getting daily stats model: $e');
      return null;
    }
  }

  /// Get daily stats for a date range
  Future<List<DailyStatsModel>> getDailyStatsRange(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final startDateStr = DailyStatsModel.formatDate(startDate);
      final endDateStr = DailyStatsModel.formatDate(endDate);

      final query = await _firestore
          .collection('dailyStats')
          .doc(userId)
          .collection('dates')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startDateStr)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endDateStr)
          .orderBy(FieldPath.documentId)
          .get();

      return query.docs.map((doc) => 
        DailyStatsModel.fromJson(doc.data(), userId, doc.id)
      ).toList();
    } catch (e) {
      print('Error getting daily stats range: $e');
      return [];
    }
  }

  /// Get weekly stats (last 7 days)
  Future<List<DailyStatsModel>> getWeeklyStats(String userId) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 6));
    return getDailyStatsRange(userId, startDate, endDate);
  }

  /// Get monthly stats (current month)
  Future<List<DailyStatsModel>> getMonthlyStats(String userId) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);
    return getDailyStatsRange(userId, startDate, endDate);
  }

  /// Get daily stats as stream for real-time updates
  Stream<DailyStatsModel?> getDailyStatsStream(String userId, DateTime date) {
    final dateStr = DailyStatsModel.formatDate(date);
    
    return _firestore
        .collection('dailyStats')
        .doc(userId)
        .collection('dates')
        .doc(dateStr)
        .snapshots()
        .map((doc) => doc.exists 
            ? DailyStatsModel.fromJson(doc.data()!, userId, dateStr) 
            : null);
  }

  /// Calculate average daily intake over a period
  Future<Map<String, double>> getAverageIntake(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final statsList = await getDailyStatsRange(userId, startDate, endDate);
      
      if (statsList.isEmpty) {
        return {
          'calories': 0.0,
          'protein': 0.0,
          'carbs': 0.0,
          'fat': 0.0,
        };
      }

      final totals = statsList.fold<Map<String, double>>({
        'calories': 0.0,
        'protein': 0.0,
        'carbs': 0.0,
        'fat': 0.0,
      }, (totals, stats) {
        totals['calories'] = totals['calories']! + stats.totalCalories;
        totals['protein'] = totals['protein']! + stats.totalProtein;
        totals['carbs'] = totals['carbs']! + stats.totalCarbs;
        totals['fat'] = totals['fat']! + stats.totalFat;
        return totals;
      });

      final days = statsList.length;
      return {
        'calories': totals['calories']! / days,
        'protein': totals['protein']! / days,
        'carbs': totals['carbs']! / days,
        'fat': totals['fat']! / days,
      };
    } catch (e) {
      print('Error calculating average intake: $e');
      return {
        'calories': 0.0,
        'protein': 0.0,
        'carbs': 0.0,
        'fat': 0.0,
      };
    }
  }

  /// Get nutrition goals based on user profile
  Future<Map<String, double>> getRecommendedIntake(String userId) async {
    try {
      final user = await getUser(userId);
      if (user == null) {
        return _getDefaultIntakeGoals();
      }

      // Basic BMR calculation (Harris-Benedict)
      double bmr;
      if (user.gender.toLowerCase() == 'male') {
        bmr = 88.362 + (13.397 * user.weight) + (4.799 * user.height) - (5.677 * user.age);
      } else {
        bmr = 447.593 + (9.247 * user.weight) + (3.098 * user.height) - (4.330 * user.age);
      }

      // Activity multiplier (assuming moderate activity)
      double tdee = bmr * 1.5;

      // Adjust based on goal
      switch (user.goal.toLowerCase()) {
        case 'lose_weight':
          tdee *= 0.85; // 15% deficit
          break;
        case 'gain_weight':
        case 'gain_muscle':
          tdee *= 1.15; // 15% surplus
          break;
        case 'maintain':
        default:
          // Keep TDEE as is
          break;
      }

      return {
        'calories': tdee,
        'protein': user.weight * 1.8, // 1.8g per kg body weight
        'carbs': (tdee * 0.45) / 4, // 45% of calories from carbs
        'fat': (tdee * 0.25) / 9, // 25% of calories from fat
      };
    } catch (e) {
      print('Error calculating recommended intake: $e');
      return _getDefaultIntakeGoals();
    }
  }

  Map<String, double> _getDefaultIntakeGoals() {
    return {
      'calories': 2000.0,
      'protein': 150.0,
      'carbs': 225.0,
      'fat': 55.0,
    };
  }
}