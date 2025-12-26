import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:makla_app/providers/auth_provider.dart';
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
  Widget build(BuildContext context) {
    // Dummy user data
    const String userName = 'Lucho Aquino';
    const String userEmail = 'luchoaquino1101@gmail.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.white,
        elevation: 1,
      ),
      backgroundColor: AppColors.lightGrey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.person, size: 80, color: AppColors.white),
            ),
            const SizedBox(height: 15),
            Text(userName, style: AppTextStyles.subtitle),
            const SizedBox(height: 5),
            Text(
              userEmail,
              style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            _buildProfileMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu() {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Account',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.replay,
            title: 'Restart Test',
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
