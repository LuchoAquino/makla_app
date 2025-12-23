import 'dart:async'; // for the Timer()
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:makla_app/screens/welcome_screen.dart';
import 'package:makla_app/utils/app_theme.dart';

// LOADINGSCREEN WIDGET
// It can change over time
// Flutter separates it into: 1.- Widget (configuration), 2.- State (logic + mutable data)
class LoadingScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  // Constructor
  const LoadingScreen({super.key, required this.cameras});

  @override
  // State -> What this widget does and
  // createState() -> Who controls this widget
  State<LoadingScreen> createState() => _LoadingScreenState(); // State is the mutable part of a StatefulWidget, This State belongs to LoadingScreen
}

// The underscore _ means private to this file
// Holds:
// - timers
// - navigation logic
// - lifecycle methods

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  // Called once when the widget is inserted into the tree (best place to start timers, fetch data, initilize controlers)
  void initState() {
    super.initState(); // Calls parent init, Always required
    Timer(const Duration(seconds: 5), () {
      // Checks if widget is still on screen, VERY important for async code
      if (mounted) {
        // Navigates to another screen, pushReplacement -> remove current screen and replaces it with new one
        Navigator.of(context).pushReplacement(
          // Defines a route (page transition)
          MaterialPageRoute(
            builder: (context) => WelcomeScreen(cameras: widget.cameras),
          ),
        );
      }
    });
  }

  @override
  // Describes what the screen looks like, call at at first render and on every rebuid
  Widget build(BuildContext context) {
    return Scaffold(
      // Centers its child on screen
      body: Center(
        // Lays out children vertically
        child: Column(
          // Centers children vertically
          mainAxisAlignment: MainAxisAlignment.center,
          // List of widgets inside the column
          children: [
            // Placeholder for the logo
            const Icon(
              Icons.fastfood, // Using a placeholder icon
              size: 100,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 20), // Adds vertical spacing
            Text('MaklaApp', style: AppTextStyles.title),
          ],
        ),
      ),
    );
  }
}
