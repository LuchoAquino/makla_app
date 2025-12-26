import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:makla_app/screens/login_screen.dart';
import 'package:makla_app/utils/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  const WelcomeScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Text(
              'Welcome to MaklaApp',
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Your personal AI nutrition assistant.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(fontSize: 18),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(cameras: cameras),
                  ),
                );
              },
              child: Text('Continue', style: AppTextStyles.button),
            ),
          ],
        ),
      ),
    );
  }
}
