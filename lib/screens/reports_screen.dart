import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/gym_service.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gym = GymService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        elevation: 0,
        title: const Text('Reports & Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportTile(
            context,
            icon: Icons.file_download,
            title: 'Export Members CSV / Excel',
            subtitle: 'Export full member list with phone, plan and dues',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting members data to CSV...')),
              );
            },
          ),
          _buildReportTile(
            context,
            icon: Icons.calendar_today,
            title: 'Monthly Collection Report',
            subtitle: 'Overview of monthly admission and renewal payments',
            onTap: () {},
          ),
          _buildReportTile(
            context,
            icon: Icons.warning_amber_rounded,
            title: 'Dues & Defaulters List',
            subtitle: 'List of members with pending balances',
            onTap: () {},
          ),
          _buildReportTile(
            context,
            icon: Icons.hourglass_bottom,
            title: 'Expiring Memberships',
            subtitle: 'Members due for renewal in next 1 to 15 days',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildReportTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryTeal.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primaryTeal),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
