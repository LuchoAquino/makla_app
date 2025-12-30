import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:makla_app/screens/main_screen.dart';
import 'package:makla_app/screens/pre_test_screen.dart';
import 'package:makla_app/utils/app_theme.dart';
import 'package:makla_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:makla_app/providers/db_user_provider.dart';
import 'package:makla_app/models/user_model.dart';

// We use StatefulWidget because the screen changes over time (login/sign-up toggle).
class LoginScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const LoginScreen({super.key, required this.cameras});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true; // To toggle between Login and Sign Up
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  // Defines UI layout -> full screen layout: background, app bar, body
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // White background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.fastfood, size: 80, color: AppColors.secondary),
            const SizedBox(height: 16),
            Text(
              _isLogin ? 'Welcome Back!' : 'Create Account',
              textAlign: TextAlign.center,
              style: AppTextStyles.title,
            ),
            const SizedBox(height: 40),
            _buildEmailForm(),
            const SizedBox(height: 20),
            _buildSocialButtons(),
            const SizedBox(height: 20),
            _buildToggleView(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_isLogin)
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () async {
            try {
              if (_isLogin) {
                // LOGIN LOGIC
                await authService.value.signIn(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                );

                // Navigation to MainScreen,
                if (!mounted) return;

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MainScreen(cameras: widget.cameras),
                  ),
                );
              } else {
                // --- SIGN UP LOGIC ---

                // 1. Create Auth Account
                final userCredential = await authService.value.createAccount(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                );

                // 2. Prepare the Data Model
                // We create a basic user.
                // Note: Age/Weight/Height are 0 for now because we fill them in TestScreen
                UserModel newUser = UserModel(
                  id: userCredential.user!.uid,
                  name: _nameController.text.trim(),
                  email: _emailController.text.trim(),
                  dateOfBirth: DateTime(2000, 1, 1),
                  weight: 0.0,
                  height: 0.0,
                  gender: "",
                  goal: "",
                  purposes: [],
                  restrictions: [],
                  diseases: [],
                  createdAt: DateTime.now(),
                );

                // 3. Save to Firestore using your new DBProvider
                // We use 'listen: false' because we are inside a function, not the UI
                if (context.mounted) {
                  await Provider.of<DbUserProvider>(
                    context,
                    listen: false,
                  ).saveNewUser(newUser);
                }

                // 4. Navigate to PreTestScreen
                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) =>
                        PreTestScreen(cameras: widget.cameras),
                  ),
                );
              }
            } catch (e) {
              if (!mounted) return;

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(e.toString())));
            }
          },

          child: Text(
            _isLogin ? 'Login' : 'Sign Up',
            style: AppTextStyles.button,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        const Text('Or continue with'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Button
            IconButton(
              iconSize: 48,
              onPressed: () {
                print('Google Sign In');
              },
              icon: Image.asset(
                'assets/icons/google_icon.png',
                errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata),
              ),
            ),
            const SizedBox(width: 20),
            // Facebook Button
            IconButton(
              iconSize: 48,
              onPressed: () {
                print('Facebook Sign In');
              },
              icon: Image.asset(
                'assets/icons/facebook_icon.png',
                errorBuilder: (c, e, s) => const Icon(Icons.facebook),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleView() {
    return TextButton(
      onPressed: () {
        setState(() {
          _isLogin = !_isLogin;
        });
      },
      child: Text(
        _isLogin
            ? 'Don\'t have an account? Sign Up'
            : 'Already have an account? Login',
        style: const TextStyle(color: AppColors.secondary),
      ),
    );
  }
}
