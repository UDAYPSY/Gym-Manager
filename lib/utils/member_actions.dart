import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/gym_models.dart';
import '../services/gym_service.dart';
import '../widgets/gym_pass_sheet.dart';
import '../widgets/whatsapp_message_sheet.dart';
import '../widgets/block_member_dialog.dart';
import '../screens/renew_plan_screen.dart';

class MemberActions {
  // 1. ID Card -> Opens Gym Pass with Modern, Classic, Bold styles
  static void openIdCard(BuildContext context, GymMember member) {
    GymPassSheet.show(context, member);
  }

  // 2. Call -> Directly triggers phone call dialer
  static Future<void> makePhoneCall(BuildContext context, GymMember member) async {
    final cleanPhone = '${member.countryCode}${member.phone}'.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // In tests / emulators without dialer
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calling ${member.fullName} (${member.countryCode} ${member.phone})...')),
      );
    }
  }

  // 3. WhatsApp -> Opens WhatsApp message bottom sheet with templates
  static void openWhatsApp(BuildContext context, GymMember member) {
    WhatsAppMessageSheet.show(context, member);
  }

  // 4. Attendance -> Instantly records attendance
  static void markAttendance(BuildContext context, GymMember member) {
    final now = DateTime.now();
    final timeStr = DateFormat('hh:mm a').format(now);
    GymService().recordAttendance(member.id, checkInTime: timeStr);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attendance marked for ${member.fullName} at $timeStr')),
    );
  }

  // 5. Renew Plan -> Opens dedicated Renew Plan screen
  static void renewPlan(BuildContext context, GymMember member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RenewPlanScreen(member: member),
      ),
    );
  }

  // 6. Block Member -> Opens Block confirmation dialog
  static void blockMember(BuildContext context, GymMember member) {
    BlockMemberDialog.show(context, member);
  }
}
