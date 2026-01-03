import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_config.dart';

class OpenAIService {
  /// Send a message to OpenAI-compatible API and get a response
  Future<String> sendMessage(String message, {List<Map<String, String>>? conversationHistory}) async {
    try {
      print('🔵 Sending message: $message');
      
      // Prepare the conversation context
      List<Map<String, String>> messages = [];
      
      // Add system message for nutrition context
      messages.add({
        'role': 'system',
        'content': '''You are NutriDoc, a helpful nutrition assistant. You provide accurate, 
        evidence-based nutritional advice and information. Be friendly, encouraging, and 
        focus on healthy eating habits. Keep responses concise but informative.'''
      });
      
      // Add conversation history if provided
      if (conversationHistory != null) {
        messages.addAll(conversationHistory);
      }
      
      // Add the current user message
      messages.add({
        'role': 'user',
        'content': message
      });

      print('🔵 Making API request to: ${AppConfig.AIBaseUrl}chat/completions');

      // Make the API request
      final response = await http.post(
        Uri.parse('${AppConfig.AIBaseUrl}chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.AIApiKey}',
        },
        body: jsonEncode({
          'model': AppConfig.AIModel,
          'messages': messages,
          'max_completion_tokens': 2000,  // ✅ Fixed for gpt-5-nano
          'stream': false,
        }),
      );

      print('🔵 Response status: ${response.statusCode}');
      print('🔵 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Validate response structure
        if (data['choices'] != null && 
            data['choices'].isNotEmpty && 
            data['choices'][0]['message'] != null &&
            data['choices'][0]['message']['content'] != null) {
          
          final aiResponse = data['choices'][0]['message']['content'];
          print('✅ AI Response: $aiResponse');
          return aiResponse.trim();
        } else {
          print('🔴 Invalid response structure: $data');
          return 'Sorry, I received an invalid response. Please try again.';
        }
        
      } else {
        print('🔴 API Error: ${response.statusCode} - ${response.body}');
        return 'Sorry, I\'m having trouble connecting to my AI service. Please try again.';
      }
      
    } catch (e, stackTrace) {
      print('🔴 Error sending message to OpenAI: $e');
      print('🔴 Stack trace: $stackTrace');
      return 'Sorry, something went wrong. Please try again.';
    }
  }

  /// Send a nutrition-specific query
  Future<String> getNutritionAdvice(String foodItem) async {
    final nutritionQuery = '''
    Tell me about the nutritional value and health implications of $foodItem. 
    Include information about calories, macronutrients, vitamins, and any health benefits or concerns.
    ''';
    
    return await sendMessage(nutritionQuery);
  }

  /// Get meal suggestions based on dietary requirements
  Future<String> getMealSuggestions(String dietaryRequirements) async {
    final mealQuery = '''
    Suggest healthy meal options for someone with these dietary requirements: $dietaryRequirements.
    Include specific meal ideas with brief nutritional highlights.
    ''';
    
    return await sendMessage(mealQuery);
  }

  /// List available models from OpenAI-compatible API
  Future<List<String>> listAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.AIBaseUrl}models'),
        headers: {
          'Authorization': 'Bearer ${AppConfig.AIApiKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract model IDs from the response
        if (data['data'] != null) {
          List<String> modelIds = [];
          for (var model in data['data']) {
            if (model['id'] != null) {
              modelIds.add(model['id'].toString());
            }
          }
          return modelIds;
        } else {
          print('No models data found in response');
          return [];
        }
      } else {
        print('Error fetching models: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching available models: $e');
      return [];
    }
  }
}