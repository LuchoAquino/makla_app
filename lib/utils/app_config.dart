import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration constants for the Makla App
class AppConfig {
  //  OpenAI Configuration
  static String get AIApiKey => dotenv.env['AI_API_KEY'] ?? '';
  static String get AIBaseUrl => dotenv.env['AI_BASE_URL'] ?? 'https://api.openai.com/v1/';
  static String get AIModel => dotenv.env['AI_MODEL'] ?? 'gpt-4o';
  
  // Other API configurations
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}
