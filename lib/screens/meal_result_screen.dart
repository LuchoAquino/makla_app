import 'dart:io';
import 'package:flutter/material.dart';
import 'package:makla_app/models/meal_model.dart';
import 'package:makla_app/providers/db_user_provider.dart';
import 'package:makla_app/providers/gemini_service.dart';
import 'package:makla_app/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MealResultScreen extends StatefulWidget {
  final String imagePath; // Path to the photo taken with the camera
  const MealResultScreen({super.key, required this.imagePath});

  @override
  State<MealResultScreen> createState() => _MealResultScreenState();
}

class _MealResultScreenState extends State<MealResultScreen> {
  // Service responsible for communicating with Google Gemini AI
  final GeminiService _geminiService = GeminiService();

  // Future to handle the asynchronous state of the AI analysis
  late Future<MealModel> _analysisFuture;

  // --- DROPDOWN LOGIC ---
  // List of valid meal types the user can select
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  // Variable to store what the user selected (initially null)
  String? _selectedMealType;

  @override
  void initState() {
    super.initState();
    // TRIGGER ANALYSIS:
    // As soon as this screen opens, we send the image to Gemini.
    // We store the result in a Future variable to use it in the UI later.
    _analysisFuture = _geminiService.analyzeFoodImage(File(widget.imagePath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        backgroundColor: AppColors.white,
        elevation: 0,
        titleTextStyle: AppTextStyles.subtitle,
        iconTheme: const IconThemeData(color: AppColors.secondary),
      ),
      backgroundColor: AppColors.lightGrey,

      // FutureBuilder listens to the _analysisFuture.
      // It rebuilds the UI based on whether the AI is still thinking, failed, or finished.
      body: FutureBuilder<MealModel>(
        future: _analysisFuture,
        builder: (context, snapshot) {
          // 1. LOADING STATE: The AI is thinking
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.secondary),
                  const SizedBox(height: 20),
                  Text(
                    "NutriDoc is analyzing your food...",
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Detecting ingredients & macros 🍎🤖",
                    style: AppTextStyles.body.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          // 2. ERROR STATE: Something went wrong (e.g., no internet)
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text("Error: ${snapshot.error}"),
              ),
            );
          }
          // 3. SUCCESS STATE: We have the data!
          else if (snapshot.hasData) {
            final meal = snapshot.data!;

            // --- INITIALIZATION LOGIC ---
            // This runs only once when we first get the data.
            // We set the dropdown value to what the AI guessed (e.g., "Lunch").
            if (_selectedMealType == null) {
              if (_mealTypes.contains(meal.mealType)) {
                _selectedMealType = meal.mealType;
              } else {
                _selectedMealType = 'Snack'; // Default fallback
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // A. SHOW IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(widget.imagePath), // Load from local file
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // B. MEAL TYPE SELECTOR (Dropdown)
                  // Allows the user to correct the AI (e.g., change Lunch to Dinner)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.secondary),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMealType,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.secondary,
                        ),
                        style: AppTextStyles.subtitle.copyWith(fontSize: 18),
                        items: _mealTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          // Update the UI when user selects a new option
                          setState(() {
                            _selectedMealType = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // C. DISH DETAILS (Name & Description)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.dishName,
                          style: AppTextStyles.title.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 10),
                        Text(meal.description, style: AppTextStyles.body),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // D. NUTRITION FACTS CARD
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text("Nutrition Facts", style: AppTextStyles.subtitle),
                        const Divider(),
                        _buildNutriRow(
                          "🔥 Calories",
                          "${meal.nutritionalInfo.calories} kcal",
                        ),
                        _buildNutriRow(
                          "🥩 Protein",
                          "${meal.nutritionalInfo.protein}g",
                        ),
                        _buildNutriRow(
                          "🍞 Carbs",
                          "${meal.nutritionalInfo.carbs}g",
                        ),
                        _buildNutriRow(
                          "🥑 Fat",
                          "${meal.nutritionalInfo.fat}g",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // E. SAVE BUTTON (CRITICAL LOGIC)
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // 1. Access the Database Provider
                        final userProvider = Provider.of<DbUserProvider>(
                          context,
                          listen: false,
                        );

                        // 2. Safety Check: Ensure User Data is Loaded
                        // If user entered via Camera directly, userCurrent might be null.
                        // We fetch it manually from Firebase Auth if needed.
                        if (userProvider.userCurrent == null) {
                          final currentUser = FirebaseAuth.instance.currentUser;
                          if (currentUser != null) {
                            await userProvider.getUserData(currentUser.uid);
                          }
                        }

                        // 3. Create the Final Meal Object
                        // We take the AI data (meal) but REPLACE the 'mealType'
                        // with what the user selected in the Dropdown (_selectedMealType).
                        final finalMeal = meal.copyWith(
                          mealType: _selectedMealType,
                        );

                        // 4. Save to Firestore
                        await userProvider.addMeal(finalMeal);

                        // 5. Success Feedback & Navigation
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Meal saved successfully!"),
                            ),
                          );
                          Navigator.pop(context); // Go back to Camera
                        }
                      } catch (e) {
                        // Error Handling
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Save to Daily Log",
                      style: AppTextStyles.button,
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Helper widget to build a row in the nutrition table (Label -> Value)
  Widget _buildNutriRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(
            value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
