import 'package:flutter/material.dart';
import 'package:makla_app/utils/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigateToTab;
  const HomeScreen({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    // Dummy user name
    const String userName = 'Lucho';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hello, $userName!',
                    style: AppTextStyles.title.copyWith(fontSize: 24),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 30),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // AI Food Scanner Card
              _buildScannerCard(context),
              const SizedBox(height: 20),

              // Chat with NutriDoc Card
              _buildChatCard(context),
              const SizedBox(height: 20),

              // My Statistics Card
              _buildStatisticsCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const Icon(Icons.fastfood, size: 60, color: AppColors.secondary),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Food Scanner',
                    style: AppTextStyles.subtitle.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Scan your meal to get instant nutritional insights.',
                    style: AppTextStyles.body.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      onNavigateToTab(1); // Navigate to CameraScreen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                    ),
                    child: Text(
                      'Scan Meal',
                      style: AppTextStyles.button.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.white,
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: const Icon(Icons.chat, size: 40, color: AppColors.secondary),
        title: Text(
          'Chat with NutriDoc',
          style: AppTextStyles.subtitle.copyWith(fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          onNavigateToTab(2); // Navigate to ChatScreen
        },
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Statistics',
              style: AppTextStyles.subtitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.7,
              child: Container(
                color: AppColors.lightGrey,
                child: const Center(child: Text('Bar chart will be here')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
