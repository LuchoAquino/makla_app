import 'package:flutter/material.dart';
import 'package:makla_app/providers/db_user_provider.dart';
import 'package:makla_app/utils/app_theme.dart';
import 'package:provider/provider.dart';

class UserDataScreen extends StatelessWidget {
  const UserDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el usuario del provider
    final user = Provider.of<DbUserProvider>(context).userCurrent;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("No user data found")));
    }

    return Scaffold(
      // Fondo gris claro para que resalten las tarjetas blancas (como en Home/Profile)
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text('My Information'),
        backgroundColor: AppColors.white,
        elevation: 1,
        centerTitle: true,
        // Ícono de regreso en color secundario
        iconTheme: const IconThemeData(color: AppColors.secondary),
        titleTextStyle: AppTextStyles.subtitle.copyWith(
          color: AppColors.secondary,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // TARJETA 1: DATOS PERSONALES
            _buildInfoCard(
              title: "Personal Details",
              icon: Icons.person_outline,
              children: [
                _buildRow("Name", user.name),
                _buildDivider(),
                _buildRow("Email", user.email),
                _buildDivider(),
                _buildRow(
                  "Date of Birth",
                  "${user.dateOfBirth.toLocal()}".split(' ')[0],
                ),
                _buildDivider(),
                _buildRow("Age", "${user.age} years"),
                _buildDivider(),
                _buildRow("Gender", user.gender),
              ],
            ),

            const SizedBox(height: 20),

            // TARJETA 2: DATOS FÍSICOS
            _buildInfoCard(
              title: "Body Measurements",
              icon: Icons.monitor_weight_outlined,
              children: [
                _buildRow("Height", "${user.height} cm"),
                _buildDivider(),
                _buildRow("Weight", "${user.weight} kg"),
              ],
            ),

            const SizedBox(height: 20),

            // TARJETA 3: SALUD Y OBJETIVOS
            _buildInfoCard(
              title: "Health & Goals",
              icon: Icons.favorite_outline,
              children: [
                _buildRow("Main Goal", user.goal),
                _buildDivider(),
                _buildRow("Check-in", user.checkInFrequency),
                _buildDivider(),
                // Listas (Purposes, Allergies, Diseases)
                _buildChipRow("Purposes", user.purposes),
                _buildDivider(),
                _buildChipRow("Dietary Restrictions", user.restrictions),
                _buildDivider(),
                _buildChipRow("Diseases", user.diseases),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET HELPER: Crea la tarjeta blanca estilo HomeScreen
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la tarjeta con ícono
            Row(
              children: [
                Icon(icon, color: AppColors.accent, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Contenido de la tarjeta
            ...children,
          ],
        ),
      ),
    );
  }

  // WIDGET HELPER: Fila simple (Etiqueta : Valor)
  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              textAlign: TextAlign.end,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET HELPER: Fila para listas (Chips)
  Widget _buildChipRow(String label, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Text(
                  item,
                  style: AppTextStyles.body.copyWith(fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // WIDGET HELPER: Línea divisoria sutil
  Widget _buildDivider() {
    return Divider(color: Colors.grey.withOpacity(0.1), height: 16);
  }
}
