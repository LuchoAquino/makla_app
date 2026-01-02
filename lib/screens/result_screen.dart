import 'dart:io';
import 'package:flutter/material.dart';
import 'package:makla_app/providers/gemini_service.dart';
import 'package:makla_app/models/nutrition_model.dart';
import 'package:makla_app/utils/app_theme.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  
  const ResultScreen({super.key, required this.imagePath});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  // Analysis results
  String dishName = '';
  String description = '';
  List<String> ingredients = [];
  String servingSize = '';
  NutritionModel? nutrition;
  String confidence = '';

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final imageFile = File(widget.imagePath);
      final analysisResult = await _geminiService.analyzeFoodImage(imageFile);
      
      // Parse the results
      dishName = analysisResult['dishName'] ?? 'Unknown Dish';
      description = analysisResult['description'] ?? 'No description available';
      ingredients = List<String>.from(analysisResult['ingredients'] ?? []);
      servingSize = analysisResult['servingSize'] ?? 'Unknown serving size';
      confidence = analysisResult['confidence'] ?? 'unknown';
      
      // Convert to nutrition model
      nutrition = _geminiService.parseNutritionData(analysisResult);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Food Analysis', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[300],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error, color: Colors.red, size: 50),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Loading or Error State
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.white),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing your food...',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ],
                ),
              )
            else if (_hasError)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 50),
                    const SizedBox(height: 8),
                    const Text(
                      'Analysis Failed',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _analyzeImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry Analysis'),
                    ),
                  ],
                ),
              )
            else
              // Results
              _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dish Information
        _buildInfoCard(
          title: 'Dish Information',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Dish Name', dishName),
              const SizedBox(height: 8),
              _buildInfoRow('Description', description),
              const SizedBox(height: 8),
              _buildInfoRow('Serving Size', servingSize),
              const SizedBox(height: 8),
              _buildInfoRow('Confidence', confidence.toUpperCase()),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Ingredients
        _buildInfoCard(
          title: 'Ingredients',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ingredients.map((ingredient) => Chip(
              label: Text(ingredient),
              backgroundColor: AppColors.secondary.withOpacity(0.2),
            )).toList(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Nutritional Information
        if (nutrition != null)
          _buildInfoCard(
            title: 'Nutritional Information',
            child: Column(
              children: [
                _buildNutritionRow('Calories', '${nutrition!.calories.toStringAsFixed(0)} kcal'),
                _buildNutritionRow('Protein', '${nutrition!.protein.toStringAsFixed(1)} g'),
                _buildNutritionRow('Carbohydrates', '${nutrition!.carbs.toStringAsFixed(1)} g'),
                _buildNutritionRow('Fat', '${nutrition!.fat.toStringAsFixed(1)} g'),
                _buildNutritionRow('Fiber', '${nutrition!.fiber.toStringAsFixed(1)} g'),
                _buildNutritionRow('Sugar', '${nutrition!.sugar.toStringAsFixed(1)} g'),
              ],
            ),
          ),
        
        const SizedBox(height: 24),
        
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save to meal log
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meal saved to your log!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Meal'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Take Another'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionRow(String nutrient, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nutrient,
            style: const TextStyle(color: AppColors.white),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
