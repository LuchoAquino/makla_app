import 'dart:async'; // for the Timer()
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:makla_app/screens/main_screen.dart';
import 'package:makla_app/screens/welcome_screen.dart';
import 'package:makla_app/utils/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Small delay to show the splash (optional)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // ❌ User NOT logged in → Welcome
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WelcomeScreen(cameras: widget.cameras),
        ),
      );
    } else {
      // ✅ User logged in → Main app
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainScreen(cameras: widget.cameras)),
      );
    }
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
