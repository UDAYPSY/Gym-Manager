import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class FilterBottomSheet extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onSelected;

  const FilterBottomSheet({
    Key? key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required List<String> options,
    required String selectedOption,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => FilterBottomSheet(
        options: options,
        selectedOption: selectedOption,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.78,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Centered circular teal close button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

            // Scrollable list of filter options with radio buttons
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final opt = options[index];
                  final isSelected = opt == selectedOption;

                  return InkWell(
                    onTap: () {
                      onSelected(opt);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              opt,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF222222),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? AppColors.primaryTeal
                                : const Color(0xFF4B5563),
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
