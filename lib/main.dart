import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:makla_app/providers/auth_gate.dart';
import 'package:makla_app/utils/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:makla_app/firebase_options.dart';
import 'package:makla_app/providers/db_user_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  // Main function is Future because I'm working with async function
  WidgetsFlutterBinding.ensureInitialized(); // Initializes Flutter before using native plugins

  final cameras = await availableCameras();

  // Initializing Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔍 DEBUG: listen auth changes
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user == null) {
      debugPrint("🔴 USER LOGGED OUT");
    } else {
      debugPrint("🟢 USER LOGGED IN: ${user.email}");
    }
  });

  // Starts the Flutter app, Injects cameras into the widget tree
  runApp(
    // Wrap MyApp in MultiProvider
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DbUserProvider())],
      child: MyApp(cameras: cameras),
    ),
  );
}

class MyApp extends StatelessWidget {
  // Stores camera list globally for the app
  final List<CameraDescription> cameras;

  // Constructor
  const MyApp({super.key, required this.cameras});

  // @override is an annotation, he said: I am intentionally replacing a method from a parent class
  @override
  // build -> What this widget looks like
  Widget build(BuildContext context) {
    // BuildContext is where your widget lives in the widget tree.
    return MaterialApp(
      title: 'MaklaApp',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.primary,
        textTheme: TextTheme(
          displayLarge: AppTextStyles.title,
          displayMedium: AppTextStyles.subtitle,
          bodyMedium: AppTextStyles.body,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.secondary),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      // home: LoadingScreen(cameras: cameras),
      home: AuthGate(cameras: cameras),

      debugShowCheckedModeBanner: false, // Removes debug banner
    );
  }
}
