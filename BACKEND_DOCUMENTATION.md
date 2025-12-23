# 🍽️ Makla App - Backend Documentation

## 📋 Overview
Makla is a **meal tracking application with AI nutritional analysis**. This document explains the complete backend architecture, database structure, and all service methods.

---

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │────│   Services      │────│   Firebase      │
│                 │    │                 │    │                 │
│ • UI Screens    │    │ • DatabaseService│    │ • Firestore     │
│ • User Input    │    │ • GeminiService │    │ • Storage       │
│ • Photo Capture │    │ • StorageService│    │ • Auth          │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **Data Flow:**
1. **User takes photo** → `StorageService` uploads to Firebase Storage
2. **AI analyzes photo** → `GeminiService` calls Google Gemini API
3. **Save meal data** → `DatabaseService` stores in Firestore
4. **Update daily stats** → Auto-calculated nutrition summaries
5. **Display insights** → Real-time analytics and progress tracking

---

## 🗄️ Database Schema (Firestore)

### **Collection Structure:**
```
📁 users/
  └── 📄 {userId}
      ├── name: string
      ├── email: string
      ├── age: number
      ├── weight: number (kg)
      ├── height: number (cm)
      ├── gender: string
      ├── goal: string
      └── createdAt: timestamp

📁 users/{userId}/meals/
  └── 📄 {mealId}
      ├── dishName: string
      ├── description: string
      ├── imageUrl: string
      ├── timestamp: timestamp
      ├── mealType: string
      ├── nutritionalInfo: map
      │   ├── calories: number
      │   ├── protein: number
      │   ├── carbs: number
      │   ├── fat: number
      │   ├── fiber: number
      │   └── sugar: number
      └── ingredients: array[string]

📁 dailyStats/
  └── 📄 {userId}/
      └── 📁 dates/
          └── 📄 {YYYY-MM-DD}
              ├── date: timestamp
              ├── totalCalories: number
              ├── totalProtein: number
              ├── totalCarbs: number
              ├── totalFat: number
              ├── mealsCount: number
              └── lastUpdated: timestamp
```

---

## 🎯 Service Classes

### **1. DatabaseService** 📊
*Main backend service for all Firestore operations*

### **2. GeminiService** 🤖
*AI-powered food image analysis using Google Gemini*

### **3. StorageService** 📸
*File upload management for meal images*

---

# 📊 DatabaseService Methods

## 🍽️ **MEAL MANAGEMENT**

### `saveMeal(String userId, MealModel meal) → Future<String>`
**Purpose:** Save a new meal and automatically update daily statistics

**Flow:**
```
1. Save meal to users/{userId}/meals/
2. Call _updateDailyStats() automatically
3. Return meal document ID
```

**Example:**
```dart
final mealId = await DatabaseService().saveMeal('user123', mealModel);
```

---

### `getUserMeals(String userId) → Stream<List<MealModel>>`
**Purpose:** Get real-time stream of user's meals (newest first)

**Returns:** Live-updating list of all user meals

**Example:**
```dart
StreamBuilder<List<MealModel>>(
  stream: DatabaseService().getUserMeals('user123'),
  builder: (context, snapshot) {
    final meals = snapshot.data ?? [];
    return ListView.builder(...);
  },
)
```

---

### `_updateDailyStats(userId, nutrition, mealTime) → Future<void>`
**Purpose:** Internal method to update daily nutrition totals

**Transaction Logic:**
```
IF daily stats exist for date:
    ✅ ADD nutrition values to existing totals
    ✅ INCREMENT mealsCount by 1
ELSE:
    ✅ CREATE new daily stats document
    ✅ SET initial nutrition values
```

**Date Format:** `YYYY-MM-DD` (e.g., "2025-12-23")

---

## 👤 **USER MANAGEMENT**

### `saveUser(UserModel user) → Future<void>`
**Purpose:** Create or update user profile

**Behavior:** Uses merge=true, so partial updates are safe

**Example:**
```dart
final user = UserModel(
  id: 'user123',
  name: 'John Doe',
  age: 30,
  weight: 70.0,
  height: 175.0,
  gender: 'male',
  goal: 'lose_weight'
);
await DatabaseService().saveUser(user);
```

---

### `getUser(String userId) → Future<UserModel?>`
**Purpose:** Get user profile by ID

**Returns:** UserModel or null if not found

**Example:**
```dart
final user = await DatabaseService().getUser('user123');
if (user != null) {
  print('User name: ${user.name}');
}
```

---

### `getUserStream(String userId) → Stream<UserModel?>`
**Purpose:** Real-time user profile updates

**Use Case:** Profile screens that auto-update when user changes data

**Example:**
```dart
StreamBuilder<UserModel?>(
  stream: DatabaseService().getUserStream('user123'),
  builder: (context, snapshot) {
    final user = snapshot.data;
    return Text(user?.name ?? 'Loading...');
  },
)
```

---

### `updateUser(String userId, Map<String, dynamic> updates) → Future<void>`
**Purpose:** Update specific user fields without overwriting entire profile

**Example:**
```dart
// Update only weight
await DatabaseService().updateUser('user123', {
  'weight': 72.5,
  'goal': 'maintain'
});
```

---

### `deleteUser(String userId) → Future<void>`
**Purpose:** Completely remove user and ALL their data

**Deletes:**
- ❌ User profile
- ❌ All user meals
- ❌ All daily stats
- ❌ Stats parent document

**⚠️ Warning:** This is irreversible!

---

## 📈 **DAILY STATS MANAGEMENT**

### `getDailyStatsModel(String userId, DateTime date) → Future<DailyStatsModel?>`
**Purpose:** Get nutrition summary for a specific date

**Example:**
```dart
final todayStats = await DatabaseService().getDailyStatsModel('user123', DateTime.now());
if (todayStats != null) {
  print('Calories today: ${todayStats.totalCalories}');
}
```

---

### `getDailyStatsRange(userId, startDate, endDate) → Future<List<DailyStatsModel>>`
**Purpose:** Get nutrition data for a date range

**Query Logic:**
```sql
WHERE documentId >= "2025-12-01" 
  AND documentId <= "2025-12-31"
ORDER BY documentId ASC
```

**Example:**
```dart
final startDate = DateTime(2025, 12, 1);
final endDate = DateTime(2025, 12, 31);
final monthStats = await DatabaseService().getDailyStatsRange('user123', startDate, endDate);

print('Days tracked: ${monthStats.length}');
```

---

### `getWeeklyStats(String userId) → Future<List<DailyStatsModel>>`
**Purpose:** Get last 7 days of nutrition data

**Calculation:**
```dart
endDate = DateTime.now()
startDate = endDate - 6 days
return getDailyStatsRange(userId, startDate, endDate)
```

---

### `getMonthlyStats(String userId) → Future<List<DailyStatsModel>>`
**Purpose:** Get current month's nutrition data

**Calculation:**
```dart
startDate = First day of current month
endDate = Last day of current month
return getDailyStatsRange(userId, startDate, endDate)
```

---

### `getDailyStatsStream(userId, date) → Stream<DailyStatsModel?>`
**Purpose:** Real-time updates for a specific day's stats

**Use Case:** Dashboard showing today's progress that updates as meals are added

**Example:**
```dart
StreamBuilder<DailyStatsModel?>(
  stream: DatabaseService().getDailyStatsStream('user123', DateTime.now()),
  builder: (context, snapshot) {
    final stats = snapshot.data;
    return Text('Calories: ${stats?.totalCalories ?? 0}');
  },
)
```

---

## 🧮 **ANALYTICS & INSIGHTS**

### `getAverageIntake(userId, startDate, endDate) → Future<Map<String, double>>`
**Purpose:** Calculate average daily nutrition over a period

**Algorithm:**
```
1. Get all daily stats in date range
2. Sum up all nutrition values
3. Divide by number of days
4. Return averages
```

**Returns:**
```dart
{
  'calories': 1850.5,
  'protein': 125.3,
  'carbs': 200.8,
  'fat': 65.2
}
```

**Example:**
```dart
final last30Days = DateTime.now().subtract(Duration(days: 30));
final averages = await DatabaseService().getAverageIntake('user123', last30Days, DateTime.now());
print('Average daily calories: ${averages['calories']!.toInt()}');
```

---

### `getRecommendedIntake(String userId) → Future<Map<String, double>>`
**Purpose:** Calculate personalized nutrition goals based on user profile

**Algorithm:**
```
1. Get user profile (age, weight, height, gender, goal)
2. Calculate BMR using Harris-Benedict equation
3. Apply activity multiplier (1.5x for moderate activity)
4. Adjust for goal:
   • Lose weight: -15% calories
   • Gain weight: +15% calories
   • Maintain: No change
5. Calculate macro targets:
   • Protein: 1.8g per kg body weight
   • Carbs: 45% of total calories
   • Fat: 25% of total calories
```

**BMR Formulas:**
- **Male:** 88.362 + (13.397 × weight) + (4.799 × height) - (5.677 × age)
- **Female:** 447.593 + (9.247 × weight) + (3.098 × height) - (4.330 × age)

**Example:**
```dart
final goals = await DatabaseService().getRecommendedIntake('user123');
print('Daily calorie goal: ${goals['calories']!.toInt()}');
print('Protein target: ${goals['protein']!.toInt()}g');
```

---

## 🤖 GeminiService Methods

### `analyzeFoodImage(File imageFile) → Future<Map<String, dynamic>>`
**Purpose:** AI-powered food analysis from photos

**Process:**
```
1. Convert image to base64
2. Send to Google Gemini API with nutrition analysis prompt
3. Parse JSON response
4. Return structured food data
```

**API Response Format:**
```json
{
  "dishName": "Chicken Curry",
  "description": "Spicy Indian curry with rice",
  "ingredients": ["chicken", "curry powder", "rice", "onion"],
  "servingSize": "1 plate (300g)",
  "nutritionalInfo": {
    "calories": 450,
    "protein": 25,
    "carbs": 40,
    "fat": 18,
    "fiber": 3,
    "sugar": 5
  },
  "confidence": "high"
}
```

---

### `parseNutritionData(Map<String, dynamic> geminiResponse) → NutritionModel`
**Purpose:** Convert Gemini API response to NutritionModel object

**Example:**
```dart
final geminiData = await GeminiService().analyzeFoodImage(imageFile);
final nutrition = GeminiService().parseNutritionData(geminiData);
print('Calories: ${nutrition.calories}');
```

---

## 📸 StorageService Methods

### `uploadMealImage(File imageFile, String userId) → Future<String>`
**Purpose:** Upload meal photos to Firebase Storage

**Process:**
```
1. Generate unique filename: meal_<timestamp>.jpg
2. Create storage path: meals/{userId}/{filename}
3. Upload file to Firebase Storage
4. Return public download URL
```

**Example:**
```dart
final imageUrl = await StorageService().uploadMealImage(imageFile, 'user123');
// Returns: https://firebasestorage.googleapis.com/v0/b/.../meals/user123/meal_1703347200000.jpg
```

---

## 🔄 Complete User Journey Example

### **Adding a New Meal:**
```dart
// 1. User takes photo
final imageFile = await ImagePicker().pickImage(source: ImageSource.camera);

// 2. Upload image
final imageUrl = await StorageService().uploadMealImage(imageFile!, userId);

// 3. Analyze with AI
final geminiData = await GeminiService().analyzeFoodImage(imageFile!);
final nutrition = GeminiService().parseNutritionData(geminiData);

// 4. Create meal model
final meal = MealModel(
  dishName: geminiData['dishName'],
  description: geminiData['description'],
  imageUrl: imageUrl,
  timestamp: DateTime.now(),
  mealType: 'lunch',
  nutritionalInfo: nutrition,
  ingredients: List<String>.from(geminiData['ingredients']),
);

// 5. Save meal (automatically updates daily stats)
final mealId = await DatabaseService().saveMeal(userId, meal);

print('Meal saved with ID: $mealId');
```

### **Displaying Dashboard:**
```dart
// Get today's stats (real-time)
Stream<DailyStatsModel?> todayStats = DatabaseService().getDailyStatsStream(userId, DateTime.now());

// Get user's nutrition goals
final goals = await DatabaseService().getRecommendedIntake(userId);

// Calculate progress
StreamBuilder<DailyStatsModel?>(
  stream: todayStats,
  builder: (context, snapshot) {
    final stats = snapshot.data;
    final calorieProgress = stats != null 
        ? (stats.totalCalories / goals['calories']!) * 100 
        : 0.0;
    
    return LinearProgressIndicator(value: calorieProgress / 100);
  },
)
```

---

## 🛡️ Error Handling & Safety

### **Null Safety:**
- All methods use `??` operators for safe defaults
- Return null or empty collections when data not found
- No crashes from missing Firebase data

### **Transaction Safety:**
- Daily stats updates use Firestore transactions
- Prevents race conditions when multiple meals added quickly
- Ensures data consistency

### **Batch Operations:**
- User deletion uses batched writes
- Deletes all related data atomically
- Either all succeed or all fail

---

## 🚀 Performance Considerations

### **Efficient Queries:**
- Date range queries use document ID comparisons
- Indexed on timestamp fields for fast sorting
- Limited result sets to prevent large downloads

### **Real-time Updates:**
- Use streams for live data where needed
- Single-time fetches for static data
- Proper listener cleanup to prevent memory leaks

### **Caching:**
- User profiles cached in app state
- Daily goals calculated once per session
- Image URLs cached for offline viewing

---

## 📱 Next Steps for UI Development

1. **Authentication:** Add Firebase Auth integration
2. **Screens:** Create UI for each service method
3. **State Management:** Use Provider/Bloc for app state
4. **Offline Support:** Add local caching with Hive/SQLite
5. **Push Notifications:** Daily reminders and goal achievements

---

*This backend provides a complete foundation for a professional meal tracking app with AI analysis, real-time analytics, and personalized nutrition insights!* 🎯
