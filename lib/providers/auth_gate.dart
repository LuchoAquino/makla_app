import 'package:flutter/material.dart';
import 'package:makla_app/providers/auth_provider.dart';
import 'package:makla_app/screens/loading_screen.dart';
import 'package:makla_app/screens/main_screen.dart';
import 'package:makla_app/screens/welcome_screen.dart';
import 'package:camera/camera.dart';

// AuthGate decides which screen to show based on authentication state -> It is useful if I start session in other moment.
class AuthGate extends StatelessWidget {
  final List<CameraDescription> cameras;

  const AuthGate({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authService, child) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            Widget widget;
            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = LoadingScreen(cameras: cameras);
            } else if (snapshot.hasData) {
              widget = MainScreen(cameras: cameras);
            } else {
              widget = WelcomeScreen(cameras: cameras);
            }
            return widget;
          },
        );
      },
    );
  }
}
