import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'members_screen.dart';
import 'dashboard_screen.dart';
import 'reports_screen.dart';
import 'gym_screen.dart';

class MainHubScreen extends StatefulWidget {
  const MainHubScreen({Key? key}) : super(key: key);

  @override
  State<MainHubScreen> createState() => _MainHubScreenState();
}

class _MainHubScreenState extends State<MainHubScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MembersScreen(),
    DashboardScreen(),
    ReportsScreen(),
    GymScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      label: 'Members',
                      icon: Icons.group,
                    ),
                    _buildNavItem(
                      index: 1,
                      label: 'Dashboard',
                      icon: Icons.pie_chart,
                    ),
                    _buildNavItem(
                      index: 2,
                      label: 'Reports',
                      icon: Icons.description,
                    ),
                    _buildNavItem(
                      index: 3,
                      label: 'Gym',
                      icon: Icons.apartment,
                    ),
                  ],
                ),
              ),
              // Android navigation gesture indicator bar
              Container(
                width: 72,
                height: 4,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active pill indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.navIndicator : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.navSelected : AppColors.navUnselected,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.navSelected : AppColors.navUnselected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
