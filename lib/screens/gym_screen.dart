import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/gym_service.dart';
import '../widgets/currency_picker_dialog.dart';

class GymScreen extends StatelessWidget {
  const GymScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gym = GymService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        elevation: 0,
        title: const Text('Gym Details & Setup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Gym Profile Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryTeal,
                    child: Icon(Icons.fitness_center, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gym.settings.gymName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text('Branch: Sector 14, Main Hub', style: TextStyle(fontSize: 13, color: AppColors.textGray)),
                        const SizedBox(height: 2),
                        Text('Currency: ${gym.settings.currencySymbol ?? "Not Set (Click to set)"}',
                            style: const TextStyle(fontSize: 12, color: AppColors.primaryTeal, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Menu Tiles
          _buildMenuTile(
            context,
            icon: Icons.monetization_on,
            title: 'Currency Settings',
            subtitle: 'Configure currency symbol (₹, \$, €, etc.)',
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => const CurrencyPickerDialog(),
              );
            },
          ),
          _buildMenuTile(
            context,
            icon: Icons.card_membership,
            title: 'Membership Plans & Pricing',
            subtitle: 'Customize package tiers, duration and rates',
            onTap: () {},
          ),
          _buildMenuTile(
            context,
            icon: Icons.schedule,
            title: 'Batches & Shift Timings',
            subtitle: 'Configure Morning, Evening, and 24/7 access slots',
            onTap: () {},
          ),
          _buildMenuTile(
            context,
            icon: Icons.lock,
            title: 'Locker Allocation',
            subtitle: 'Manage secure locker assignments for members',
            onTap: () {},
          ),
          _buildMenuTile(
            context,
            icon: Icons.backup,
            title: 'Backup & Cloud Sync',
            subtitle: 'Secure offline backup & Firestore cloud synchronization',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryTeal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
