import 'package:flutter/material.dart';
import '../services/gym_service.dart';
import '../constants/app_colors.dart';

class CurrencyPickerDialog extends StatelessWidget {
  const CurrencyPickerDialog({Key? key}) : super(key: key);

  static final List<Map<String, String>> currencies = [
    {'symbol': '₹', 'code': 'INR', 'name': 'Indian Rupee'},
    {'symbol': '\$', 'code': 'USD', 'name': 'US Dollar'},
    {'symbol': '€', 'code': 'EUR', 'name': 'Euro'},
    {'symbol': '£', 'code': 'GBP', 'name': 'British Pound'},
    {'symbol': 'AED', 'code': 'AED', 'name': 'UAE Dirham'},
    {'symbol': 'C\$', 'code': 'CAD', 'name': 'Canadian Dollar'},
    {'symbol': 'A\$', 'code': 'AUD', 'name': 'Australian Dollar'},
    {'symbol': '৳', 'code': 'BDT', 'name': 'Bangladeshi Taka'},
    {'symbol': 'Rs', 'code': 'PKR', 'name': 'Pakistani Rupee'},
    {'symbol': 'S\$', 'code': 'SGD', 'name': 'Singapore Dollar'},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Currency',
                  style: TextStyle(
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
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: currencies.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final curr = currencies[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryTeal.withOpacity(0.1),
                      child: Text(
                        curr['symbol']!,
                        style: const TextStyle(
                          color: AppColors.primaryTeal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${curr['code']} (${curr['symbol']})',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(curr['name']!),
                    onTap: () {
                      GymService().setCurrency(curr['symbol']!, curr['code']!);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Currency set to ${curr['name']} (${curr['symbol']})'),
                          backgroundColor: AppColors.primaryTeal,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
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
