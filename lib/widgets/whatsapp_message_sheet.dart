import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../models/gym_models.dart';

class WhatsAppMessageSheet extends StatefulWidget {
  final GymMember member;

  const WhatsAppMessageSheet({super.key, required this.member});

  static void show(BuildContext context, GymMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WhatsAppMessageSheet(member: member),
    );
  }

  @override
  State<WhatsAppMessageSheet> createState() => _WhatsAppMessageSheetState();
}

class _WhatsAppMessageSheetState extends State<WhatsAppMessageSheet> {
  late TextEditingController _msgCtrl;
  String _selectedTemplate = 'Payment Confirmation';

  @override
  void initState() {
    super.initState();
    _msgCtrl = TextEditingController(
      text: 'Thank you for your purchase. We have received your payment.',
    );
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _onTemplateChanged(String template) {
    setState(() {
      _selectedTemplate = template;
      if (template == 'Payment Confirmation') {
        _msgCtrl.text = 'Thank you for your purchase. We have received your payment.';
      } else if (template == 'Payment reminders') {
        _msgCtrl.text =
            'Dear ${widget.member.fullName}, this is a gentle reminder that your gym membership payment of ₹${widget.member.duesAmount.toInt()} is pending. Please clear your dues at the earliest.';
      } else if (template == 'Add custom message') {
        _msgCtrl.text = 'Hello ${widget.member.fullName}, ';
      }
    });
  }

  Future<void> _sendMessage() async {
    final phone = '${widget.member.countryCode}${widget.member.phone}'
        .replaceAll(RegExp(r'[^\d]'), '');
    final text = _msgCtrl.text.trim();
    final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(text)}');

    Navigator.pop(context);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url);
      }
    } catch (_) {
      // Fallback
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening WhatsApp for ${widget.member.fullName}...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset > 0 ? bottomInset + 16 : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & Close Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Send Whatsapp message:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.member.countryCode}${widget.member.phone}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Color(0xFF4B5563)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Message Input Field
          TextFormField(
            controller: _msgCtrl,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
            decoration: InputDecoration(
              labelText: 'message....',
              labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          // Select Template Label
          const Text(
            'Select Template',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),

          // Template Radio Options
          _buildRadioOption('Payment Confirmation'),
          const Divider(height: 1, thickness: 0.6, color: Color(0xFFF3F4F6)),
          _buildRadioOption('Payment reminders'),
          const Divider(height: 1, thickness: 0.6, color: Color(0xFFF3F4F6)),
          _buildRadioOption('Add custom message'),
          const SizedBox(height: 20),

          // Bottom Action Row: Cancel | Send
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  elevation: 0,
                ),
                onPressed: _sendMessage,
                child: const Text(
                  'Send',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String title) {
    final isSelected = _selectedTemplate == title;
    return InkWell(
      onTap: () => _onTemplateChanged(title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryTeal : const Color(0xFF9CA3AF),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryTeal,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
