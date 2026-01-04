import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:makla_app/screens/user_info_form.dart';
import 'package:makla_app/utils/app_theme.dart';

class PreTestScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  const PreTestScreen({super.key, required this.cameras});

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
              'We will now give you a quick test to get to know you better.',
              textAlign: TextAlign.center,
              style: AppTextStyles.title,
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
                    builder: (context) => UserInfoForm(cameras: cameras),
                  ),
                );
              },
              child: Text('Start', style: AppTextStyles.button),
            ),
          ],
        ),
      ),
    );
  }
}
