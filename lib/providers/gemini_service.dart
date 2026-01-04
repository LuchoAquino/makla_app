import 'dart:io';
import 'dart:convert';
import 'package:makla_app/models/meal_model.dart';
import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {
  /// Analyze food image and return nutritional information
  Future<MealModel> analyzeFoodImage(File imageFile) async {
    try {
      // 1.- Initialize Firebase AI Gemini
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash',
      );

      // 2.- Provide a text prompt to include with the image
      final prompt = TextPart('''
Analyze this food image and provide detailed nutritional information.

Respond ONLY with a valid JSON object (no markdown, no backticks, no extra text) with this EXACT structure:
{
  "dishName": "name of the dish",
  "description": "brief description of the dish",
  "mealType": "String (Breakfast, Lunch, Dinner, Snack)", 
  "ingredients": ["ingredient1", "ingredient2", "ingredient3", ...],
  "nutritionalInfo": {
    "calories": <number>,
    "protein": <number in grams>,
    "carbs": <number in grams>,
    "fat": <number in grams>,
    "fiber": <number in grams>,
    "sugar": <number in grams>
  },
  "confidence": "high/medium/low"
}

Important:
- Estimate based on a typical restaurant portion
- All numbers should be realistic
- Be as accurate as possible
''');

      // 3.- Prepare images for input
      final image = await imageFile.readAsBytes();
      final imagePart = InlineDataPart('image/jpeg', image);

      // 4.- To generate text output, call generateContent with the text and image
      final response = await model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);
      print(response.text);

      if (response.text == null) throw Exception("AI returned empty response");

      // Clean JSON
      final cleanText = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Parse JSON
      final Map<String, dynamic> jsonMap = jsonDecode(cleanText);

      // 5. Return MealModel using the factory we created
      return MealModel.fromAIJson(jsonMap, imageFile.path);
    } catch (e) {
      print('Error analyzing food: $e');
      rethrow;
    }
  }
}
