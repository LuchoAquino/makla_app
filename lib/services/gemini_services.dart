import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nutrition_model.dart';

class GeminiService {
  static const String apiKey = 'YOUR_GEMINI_API_KEY';
  static const String apiUrl = 
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent';

  /// Analyze food image and return nutritional information
  Future<Map<String, dynamic>> analyzeFoodImage(File imageFile) async {
    try {
      // 1. Convert image to base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // 2. Create the prompt
      final prompt = '''
Analyze this food image and provide detailed nutritional information.

Respond ONLY with a valid JSON object (no markdown, no backticks, no extra text) with this EXACT structure:
{
  "dishName": "name of the dish",
  "description": "brief description of the dish",
  "ingredients": ["ingredient1", "ingredient2", "ingredient3"],
  "servingSize": "estimated serving size (e.g., 1 plate, 200g)",
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
''';

      // 3. Make API request
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.4,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 2048,
          }
        }),
      );

      // 4. Handle response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Clean and parse JSON
        final cleanText = text
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        
        final nutritionData = jsonDecode(cleanText);
        
        return nutritionData;
      } else {
        throw Exception('Gemini API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error analyzing food: $e');
      rethrow;
    }
  }

  /// Convert Gemini response to NutritionModel
  NutritionModel parseNutritionData(Map<String, dynamic> geminiResponse) {
    final nutritionInfo = geminiResponse['nutritionalInfo'];
    return NutritionModel(
      calories: (nutritionInfo['calories'] ?? 0).toDouble(),
      protein: (nutritionInfo['protein'] ?? 0).toDouble(),
      carbs: (nutritionInfo['carbs'] ?? 0).toDouble(),
      fat: (nutritionInfo['fat'] ?? 0).toDouble(),
      fiber: (nutritionInfo['fiber'] ?? 0).toDouble(),
      sugar: (nutritionInfo['sugar'] ?? 0).toDouble(),
    );
  }
}