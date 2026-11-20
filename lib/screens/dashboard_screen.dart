import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/gym_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gym = GymService();
    final currency = gym.settings.currencySymbol ?? '₹';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        elevation: 0,
        title: const Text('Gym Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textBlack),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Active Members',
                    value: '${gym.members.length}',
                    icon: Icons.people_alt,
                    color: AppColors.primaryTeal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Revenue Collected',
                    value: '$currency${gym.members.fold<double>(0, (sum, m) => sum + m.amountPaid).toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Expiring Soon',
                    value: '${gym.members.where((m) => m.daysRemaining <= 7 && !m.isExpired).length}',
                    icon: Icons.timer,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Pending Dues',
                    value: '$currency${gym.members.fold<double>(0, (sum, m) => sum + m.duesAmount).toStringAsFixed(0)}',
                    icon: Icons.money_off,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.chipBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textGray)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
