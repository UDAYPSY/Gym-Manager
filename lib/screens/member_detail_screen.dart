import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/gym_models.dart';
import '../services/gym_service.dart';

class MemberDetailScreen extends StatefulWidget {
  final GymMember member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  final GymService _gymService = GymService();
  late bool _paymentReminder;
  late DateTime _selectedMonth;

  // Selected quick filter chips (PT Plans & Attendance are selected by default as in screenshot)
  final Set<String> _selectedChips = {'PT Plans', 'Attendance'};

  @override
  void initState() {
    super.initState();
    _paymentReminder = widget.member.paymentReminder;
    _selectedMonth = widget.member.joinedDate;
  }

  GymMember _getCurrentMember() {
    final found = _gymService.members.where((m) => m.id == widget.member.id);
    if (found.isNotEmpty) return found.first;
    return widget.member;
  }

  String _formatCurrency(double amount) {
    final currency = _gymService.settings.currencySymbol ?? '₹';
    final formatter = NumberFormat('#,##,###');
    return '$currency${formatter.format(amount.toInt())}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatNumericDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GymMember>>(
      stream: _gymService.membersStream,
      initialData: _gymService.members,
      builder: (context, snapshot) {
        final member = _getCurrentMember();

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          appBar: AppBar(
            backgroundColor: AppColors.primaryTeal,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Member Detail',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Member Header Card
                _buildMemberHeaderCard(context, member),
                const SizedBox(height: 12),

                // Section 2: Biometric Access Card
                _buildBiometricAccessCard(context, member),
                const SizedBox(height: 12),

                // Section 3: Plans Section
                _buildPlansCard(context, member),
                const SizedBox(height: 14),

                // Section 4: Quick Action Filter Chips Row
                _buildQuickChipsRow(context),
                const SizedBox(height: 14),

                // Section 5: PT Plans Section (if selected)
                if (_selectedChips.contains('PT Plans')) ...[
                  _buildPtPlansCard(context, member),
                  const SizedBox(height: 12),
                ],

                // Section 6: Attendance Section (if selected)
                if (_selectedChips.contains('Attendance')) ...[
                  _buildAttendanceCard(context, member),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // SECTION 1: Member Header Card
  // ==========================================
  Widget _buildMemberHeaderCard(BuildContext context, GymMember member) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.primaryTeal, width: 4.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Member Avatar Circle
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryTeal,
                ),
                alignment: Alignment.center,
                child: member.photoBase64 != null && member.photoBase64!.isNotEmpty
                    ? ClipOval(
                        child: Image.memory(
                          base64Decode(member.photoBase64!),
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : 'M',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 14),

              // Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      member.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // M ID & Mobile Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'M ID',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                member.memberId,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mobile',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '${member.countryCode} - ${member.phone}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Gender Row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          member.gender,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),

          // 6 Quick Action Icons Row
          _buildActionIconsRow(context, member),
        ],
      ),
    );
  }

  // ==========================================
  // Action Icons Row (ID Card, Call, Whatsapp, Attendance, Renew Plan, Block Member)
  // ==========================================
  Widget _buildActionIconsRow(BuildContext context, GymMember member) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionItem(
          icon: Icons.badge_outlined,
          label: 'ID Card',
          onTap: () => _showIdCardDialog(context, member),
        ),
        _buildActionItem(
          icon: Icons.call_outlined,
          label: 'Call',
          onTap: () => _showCallDialog(context, member),
        ),
        _buildActionItem(
          icon: Icons.chat_bubble_outline,
          label: 'Whatsapp',
          onTap: () => _showWhatsappDialog(context, member),
        ),
        _buildActionItem(
          icon: Icons.touch_app_outlined,
          label: 'Attendance',
          onTap: () => _quickMarkAttendance(context, member),
        ),
        _buildActionItem(
          icon: Icons.grid_view,
          label: 'Renew Plan',
          onTap: () => _showRenewPlanDialog(context, member),
        ),
        _buildActionItem(
          icon: Icons.block_outlined,
          label: member.status == MemberStatus.blocked ? 'Unblock' : 'Block Member',
          onTap: () => _toggleBlockMember(context, member),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF374151)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SECTION 2: Biometric Access Card
  // ==========================================
  Widget _buildBiometricAccessCard(BuildContext context, GymMember member) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.primaryTeal, width: 4.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.fingerprint, color: AppColors.primaryTeal, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Biometric Access',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showBiometricConfigDialog(context, member),
                child: const Text(
                  'Configure',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Status & Biometric ID Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.biometricStatus,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Biometric ID',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.biometricId,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 10),

          // Action Buttons: Remove Biometric Access / Add Biometric Access
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  _gymService.updateBiometricStatus(
                    member.id,
                    status: 'Not Registered',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Biometric access removed')),
                  );
                },
                child: Row(
                  children: const [
                    Icon(Icons.delete_outline, size: 16, color: Color(0xFF4B5563)),
                    SizedBox(width: 4),
                    Text(
                      'Remove Biometric Ac...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4B5563),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  _gymService.updateBiometricStatus(
                    member.id,
                    status: 'Registered',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Biometric access registered successfully!')),
                  );
                },
                child: Row(
                  children: const [
                    Icon(Icons.fingerprint, size: 16, color: AppColors.primaryTeal),
                    SizedBox(width: 4),
                    Text(
                      'Add Biometric Access',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 3: Plans Card
  // ==========================================
  Widget _buildPlansCard(BuildContext context, GymMember member) {
    return Column(
      children: [
        // Top Header Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: const Border(
              left: BorderSide(color: AppColors.primaryTeal, width: 4.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.grid_view, color: AppColors.primaryTeal, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Plans',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showAllPlansModal(context, member),
                child: const Text(
                  'View All (1) >',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF00796B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Inner Plan Details Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: const Border(
              left: BorderSide(color: AppColors.primaryTeal, width: 4.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Plan Name, Edit, Trash
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plan Name',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member.planName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note, size: 22, color: Color(0xFF4B5563)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showEditPlanDialog(context, member),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF6B7280)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _confirmDeletePlan(context, member),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 2: Purchase Date & Expiry Date
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Purchase Date',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(member.joinedDate),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expiry Date',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(member.expiryDate),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 3: Complete Amount & Discount
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Complete Amount',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(member.planAmount),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Discount',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(member.discount),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 4: Paid & Due Amount
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Paid',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(member.amountPaid),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Due Amount',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(member.duesAmount),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: member.duesAmount > 0
                                ? const Color(0xFFD32F2F)
                                : const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 5: Payment reminder Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Payment reminder',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Switch(
                    value: _paymentReminder,
                    activeColor: AppColors.primaryTeal,
                    onChanged: (val) {
                      setState(() => _paymentReminder = val);
                      _gymService.togglePaymentReminder(member.id, val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 6: Payment Details Header + Add Payment Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryTeal,
                      side: const BorderSide(color: AppColors.primaryTeal),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    onPressed: () => _showAddPaymentModal(context, member),
                    icon: const Icon(Icons.credit_card_outlined, size: 16),
                    label: const Text(
                      'Add Payment',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Row 7: Payment Transaction History Item
              if (member.paymentHistory.isNotEmpty) ...[
                ...member.paymentHistory.map((payment) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  _formatNumericDate(payment.date),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Amount',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  _formatCurrency(payment.amount),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFF6B7280)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _gymService.deletePayment(member.id, payment.id);
                                },
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF6B7280)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _sharePaymentReceipt(context, member, payment),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'No payments recorded yet',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  ),
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.8, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 10),

              // Row 8: Action Links: Share Invoice / Freeze Membership
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () => _showInvoiceDialog(context, member),
                    child: Row(
                      children: const [
                        Icon(Icons.reply, size: 18, color: Color(0xFF00796B)),
                        SizedBox(width: 4),
                        Text(
                          'Share Invoice',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF00796B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _showFreezeMembershipDialog(context, member),
                    child: Row(
                      children: [
                        const Icon(Icons.ac_unit, size: 18, color: Color(0xFF00796B)),
                        const SizedBox(width: 4),
                        Text(
                          member.isFrozen ? 'Unfreeze Membership' : 'Freeze Membership',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF00796B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 4: Quick Action Filter Chips
  // ==========================================
  Widget _buildQuickChipsRow(BuildContext context) {
    final chips = [
      'Batch',
      'PT Plans',
      'Services',
      'Workout Plans',
      'Diet Plans',
      'Measurement',
      'Attendance',
      'Documents',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...chips.map((chip) {
            final isSelected = _selectedChips.contains(chip);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.check, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                    ],
                    Text(chip),
                  ],
                ),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF005C53),
                ),
                backgroundColor: Colors.white,
                selectedColor: AppColors.primaryTeal,
                selected: isSelected,
                showCheckmark: false,
                side: BorderSide(
                  color: isSelected ? AppColors.primaryTeal : const Color(0xFF005C53),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedChips.add(chip);
                    } else {
                      _selectedChips.remove(chip);
                    }
                  });
                },
              ),
            );
          }),
          // Settings gear icon
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF6B7280), size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Member profile settings')),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 5: PT Plans Section
  // ==========================================
  Widget _buildPtPlansCard(BuildContext context, GymMember member) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: AppColors.primaryTeal, width: 4.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.person, color: AppColors.primaryTeal, size: 20),
              SizedBox(width: 8),
              Text(
                'PT Plans',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No Personal Training plans assigned yet')),
              );
            },
            child: const Text(
              'View All (0) >',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF00796B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 6: Attendance Section
  // ==========================================
  Widget _buildAttendanceCard(BuildContext context, GymMember member) {
    final monthStr = DateFormat('MMM yyyy').format(_selectedMonth);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: AppColors.primaryTeal, width: 4.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Clock Icon + Attendance Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.access_time, color: AppColors.primaryTeal, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Attendance',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryTeal, size: 20),
                tooltip: 'Log Attendance',
                onPressed: () => _quickMarkAttendance(context, member),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Month Selector Row (< Nov 2026 >)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month - 1,
                    );
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_left, size: 20, color: Color(0xFF374151)),
                ),
              ),
              const SizedBox(width: 24),
              Text(
                monthStr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                ),
              ),
              const SizedBox(width: 24),
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                    );
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF374151)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Daily Attendance Entry List
          if (member.attendanceHistory.isNotEmpty) ...[
            ...member.attendanceHistory.map((att) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(att.date),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Row(
                        children: [
                          // Check-in Badge (Green)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_forward, size: 12, color: Color(0xFF2E7D32)),
                                const SizedBox(width: 4),
                                Text(
                                  att.checkInTime,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (att.checkOutTime != null) ...[
                            const SizedBox(width: 8),
                            // Check-out Badge (Yellow/Orange)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_forward, size: 12, color: Color(0xFFF57F17)),
                                  const SizedBox(width: 4),
                                  Text(
                                    att.checkOutTime!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF57F17),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                )),
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No attendance logged for this month',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // Interactive Helper Actions
  // ==========================================

  void _showIdCardDialog(BuildContext context, GymMember member) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'GYM MEMBER PASS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryTeal,
                ),
                alignment: Alignment.center,
                child: Text(
                  member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : 'M',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                member.fullName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Member ID: ${member.memberId}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                'Phone: ${member.countryCode} ${member.phone}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Valid Till: ${_formatDate(member.expiryDate)}',
                  style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              // Barcode placeholder simulation
              Container(
                height: 36,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    24,
                    (i) => Container(
                      width: i % 3 == 0 ? 3 : 1.5,
                      height: 24,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCallDialog(BuildContext context, GymMember member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.call, color: AppColors.primaryTeal),
            SizedBox(width: 8),
            Text('Call Member'),
          ],
        ),
        content: Text('Dial ${member.countryCode} - ${member.phone} for ${member.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Connecting call to ${member.phone}...')),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _showWhatsappDialog(BuildContext context, GymMember member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.chat, color: Color(0xFF25D366)),
            SizedBox(width: 8),
            Text('WhatsApp'),
          ],
        ),
        content: Text('Open WhatsApp chat with ${member.fullName} (${member.phone})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening WhatsApp with ${member.phone}...')),
              );
            },
            child: const Text('Chat'),
          ),
        ],
      ),
    );
  }

  void _quickMarkAttendance(BuildContext context, GymMember member) {
    final now = DateTime.now();
    final timeStr = DateFormat('hh:mm a').format(now);
    _gymService.recordAttendance(member.id, checkInTime: timeStr);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attendance recorded for ${member.fullName} at $timeStr')),
    );
  }

  void _showRenewPlanDialog(BuildContext context, GymMember member) {
    String selectedPeriod = '1 Month';
    double extraAmount = 4000;
    int months = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Renew Membership Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Plan: ${member.planName}'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedPeriod,
                decoration: const InputDecoration(
                  labelText: 'Extension Duration',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '1 Month', child: Text('1 Month (₹4,000)')),
                  DropdownMenuItem(value: '3 Months', child: Text('3 Months (₹10,000)')),
                  DropdownMenuItem(value: '6 Months', child: Text('6 Months (₹20,000)')),
                  DropdownMenuItem(value: '1 Year', child: Text('1 Year (₹35,000)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() {
                      selectedPeriod = val;
                      if (val == '1 Month') {
                        extraAmount = 4000;
                        months = 1;
                      } else if (val == '3 Months') {
                        extraAmount = 10000;
                        months = 3;
                      } else if (val == '6 Months') {
                        extraAmount = 20000;
                        months = 6;
                      } else {
                        extraAmount = 35000;
                        months = 12;
                      }
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                _gymService.renewPlan(
                  member.id,
                  newPlanName: '$selectedPeriod plan',
                  newPlanAmount: extraAmount,
                  durationMonths: months,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Plan renewed for $selectedPeriod!')),
                );
              },
              child: const Text('Renew'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleBlockMember(BuildContext context, GymMember member) {
    _gymService.toggleBlock(member.id);
    final isBlocked = member.status != MemberStatus.blocked;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBlocked
              ? 'Member ${member.fullName} has been blocked'
              : 'Member ${member.fullName} unblocked',
        ),
      ),
    );
  }

  void _showBiometricConfigDialog(BuildContext context, GymMember member) {
    final idCtrl = TextEditingController(text: member.biometricId);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Configure Biometrics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(
                labelText: 'Biometric Machine ID',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              _gymService.updateBiometricStatus(
                member.id,
                status: 'Registered',
                biometricId: idCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Biometric settings saved!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentModal(BuildContext context, GymMember member) {
    final amountCtrl = TextEditingController(text: member.duesAmount > 0 ? member.duesAmount.toInt().toString() : '500');
    String paymentMethod = 'Cash';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Payment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Payment Amount (₹)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'UPI / GPay / PhonePe', child: Text('UPI / GPay / PhonePe')),
                  DropdownMenuItem(value: 'Credit / Debit Card', child: Text('Credit / Debit Card')),
                  DropdownMenuItem(value: 'Net Banking', child: Text('Net Banking')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => paymentMethod = val);
                },
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final enteredAmount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                  if (enteredAmount > 0) {
                    _gymService.addPayment(
                      member.id,
                      PaymentRecord(
                        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
                        date: DateTime.now(),
                        amount: enteredAmount,
                        paymentMethod: paymentMethod,
                      ),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment of ₹$enteredAmount recorded successfully!')),
                    );
                  }
                },
                child: const Text('Record Payment', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInvoiceDialog(BuildContext context, GymMember member) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'INVOICE RECEIPT',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Text('Member: ${member.fullName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('ID: ${member.memberId} | Mobile: ${member.phone}'),
              Text('Plan: ${member.planName}'),
              Text('Date: ${_formatDate(member.joinedDate)}'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Plan Amount:'),
                        Text(_formatCurrency(member.planAmount)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discount:'),
                        Text('- ${_formatCurrency(member.discount)}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount Paid:'),
                        Text(_formatCurrency(member.amountPaid), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Remaining Due:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_formatCurrency(member.duesAmount), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice copied to clipboard / shared!')),
                  );
                },
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share Invoice'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFreezeMembershipDialog(BuildContext context, GymMember member) {
    int freezeDays = 14;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.ac_unit, color: AppColors.primaryTeal),
            SizedBox(width: 8),
            Text('Freeze Membership'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.isFrozen
                  ? 'This membership is currently frozen. Would you like to unfreeze it?'
                  : 'Freezing membership will temporarily pause validity.',
            ),
            if (!member.isFrozen) ...[
              const SizedBox(height: 12),
              const Text('Select Freeze Duration:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: freezeDays,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 7, child: Text('7 Days')),
                  DropdownMenuItem(value: 14, child: Text('14 Days')),
                  DropdownMenuItem(value: 30, child: Text('30 Days')),
                ],
                onChanged: (val) {
                  if (val != null) freezeDays = val;
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              _gymService.toggleFreeze(member.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    member.isFrozen
                        ? 'Membership unfrozen'
                        : 'Membership frozen for $freezeDays days',
                  ),
                ),
              );
            },
            child: Text(member.isFrozen ? 'Unfreeze' : 'Freeze'),
          ),
        ],
      ),
    );
  }

  void _showAllPlansModal(BuildContext context, GymMember member) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enrolled Plans',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.grid_view, color: AppColors.primaryTeal),
              title: Text(member.planName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Valid till ${_formatDate(member.expiryDate)}'),
              trailing: Text(_formatCurrency(member.planAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPlanDialog(BuildContext context, GymMember member) {
    final nameCtrl = TextEditingController(text: member.planName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Plan Name'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Plan Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                _gymService.updateMember(member.copyWith(planName: nameCtrl.text.trim()));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePlan(BuildContext context, GymMember member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Plan'),
        content: const Text('Are you sure you want to remove this plan from the member?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Plan removed')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _sharePaymentReceipt(BuildContext context, GymMember member, PaymentRecord payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Receipt for ₹${payment.amount} shared for ${member.fullName}'),
      ),
    );
  }
}
