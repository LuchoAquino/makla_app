import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get the current UID
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // To listen to the database
import 'package:makla_app/providers/auth_provider.dart';
import 'package:makla_app/providers/db_user_provider.dart'; // Your Logic Layer
import 'package:makla_app/screens/loading_screen.dart';
import 'package:makla_app/utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  // Constructor
  const ProfileScreen({super.key, required this.cameras});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // TRIGGER: When the screen opens, fetch the user data
    // We use 'addPostFrameCallback' to ensure the BuildContext is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        Provider.of<DbUserProvider>(context, listen: false).getUserData(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.white,
        elevation: 1,
      ),
      backgroundColor: AppColors.lightGrey,
      // CONSUMER: Listens to DBProvider. If it updates, this part redraws.
      body: Consumer<DbUserProvider>(
        builder: (context, dbProvider, child) {
          // 1. Loading State
          if (dbProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Data is Ready
          final user = dbProvider.userCurrent;

          // Safety check (in case data is null for some reason)
          if (user == null) {
            return const Center(child: Text("User info not found"));
          }

          // 3. Show Real Data
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.secondary,
                  child: Icon(Icons.person, size: 80, color: AppColors.white),
                ),
                const SizedBox(height: 15),
                // REAL NAME
                Text(user.name, style: AppTextStyles.subtitle),
                const SizedBox(height: 5),
                // REAL EMAIL
                Text(
                  user.email,
                  style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),
                _buildProfileMenu(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Account',
            onTap: () {
              // TODO: Navigate to Edit Profile Screen
            },
          ),
          _buildMenuItem(
            icon: Icons.replay,
            title: 'Do again the Test',
            onTap: () {},
          ),
          _buildMenuItem(icon: Icons.help_outline, title: 'Help', onTap: () {}),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Information',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.bar_chart_outlined,
            title: 'Statistics',
            onTap: () {},
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.exit_to_app,
            title: 'Sign Out',
            color: Colors.red,
            onTap: () async {
              await authService.value.signOut();
              if (mounted) {
                // Navegar al WelcomeScreen o LoadingScreen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) =>
                        LoadingScreen(cameras: widget.cameras),
                  ),
                  (route) => false, // elimina todas las rutas anteriores
                );
              }
              debugPrint("USER SIGNED OUT");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.secondary),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(
          color: color ?? AppColors.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
