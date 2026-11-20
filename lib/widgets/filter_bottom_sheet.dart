import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class FilterBottomSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onSelected;

  const FilterBottomSheet({
    Key? key,
    required this.title,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String selectedOption,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => FilterBottomSheet(
        title: title,
        options: options,
        selectedOption: selectedOption,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...options.map((opt) {
              final isSelected = opt == selectedOption;
              return ListTile(
                title: Text(
                  opt,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primaryTeal : AppColors.textBlack,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primaryTeal)
                    : null,
                onTap: () {
                  onSelected(opt);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
