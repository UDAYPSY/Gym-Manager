import 'package:flutter/material.dart';
import '../models/gym_models.dart';
import '../services/gym_service.dart';

class BlockMemberDialog {
  static void show(BuildContext context, GymMember member) {
    final isBlocked = member.status == MemberStatus.blocked;
    final actionWord = isBlocked ? 'unblock' : 'block';
    final actionBtnText = isBlocked ? 'UNBLOCK' : 'BLOCK';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Confirm?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        content: Text(
          'Are you sure you want to $actionWord ${member.fullName}?',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF374151),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'NO',
              style: TextStyle(
                color: Color(0xFF00796B),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              GymService().toggleBlock(member.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isBlocked
                        ? 'Member ${member.fullName} unblocked'
                        : 'Member ${member.fullName} blocked',
                  ),
                ),
              );
            },
            child: Text(
              actionBtnText,
              style: const TextStyle(
                color: Color(0xFF00796B),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
