import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/gym_models.dart';
import '../services/gym_service.dart';

class RenewPlanScreen extends StatefulWidget {
  final GymMember member;

  const RenewPlanScreen({super.key, required this.member});

  @override
  State<RenewPlanScreen> createState() => _RenewPlanScreenState();
}

class _RenewPlanScreenState extends State<RenewPlanScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _plans = [
    {'name': '6 month plan (20000)', 'amount': 20000.0, 'months': 6},
    {'name': '1 month plan (4000)', 'amount': 4000.0, 'months': 1},
    {'name': '3 month plan (10000)', 'amount': 10000.0, 'months': 3},
    {'name': '1 year plan (35000)', 'amount': 35000.0, 'months': 12},
  ];

  late String _selectedPlan;
  late double _planAmount;
  late int _durationMonths;

  late DateTime _planStartDate;
  DateTime? _paymentDate;

  final TextEditingController _paidAmountCtrl = TextEditingController();
  final TextEditingController _commentsCtrl = TextEditingController();
  final TextEditingController _discountCtrl = TextEditingController();
  final TextEditingController _admissionFeesCtrl = TextEditingController();

  String _paymentMethod = 'Cash';
  bool _paymentReminder = false;
  String _discountType = 'Percent'; // "Percent" or "Amount"

  @override
  void initState() {
    super.initState();
    _selectedPlan = _plans.first['name'] as String;
    _planAmount = _plans.first['amount'] as double;
    _durationMonths = _plans.first['months'] as int;

    // Start date defaults to the day after expiry date (as in screenshot)
    final baseDate = widget.member.isExpired ? DateTime.now() : widget.member.expiryDate;
    _planStartDate = baseDate.add(const Duration(days: 1));
    _paymentDate = DateTime.now();
  }

  @override
  void dispose() {
    _paidAmountCtrl.dispose();
    _commentsCtrl.dispose();
    _discountCtrl.dispose();
    _admissionFeesCtrl.dispose();
    super.dispose();
  }

  double get _dueAmount {
    final paid = double.tryParse(_paidAmountCtrl.text.trim()) ?? 0.0;
    final discountVal = double.tryParse(_discountCtrl.text.trim()) ?? 0.0;
    final admission = double.tryParse(_admissionFeesCtrl.text.trim()) ?? 0.0;

    double calculatedDiscount = 0.0;
    if (_discountType == 'Percent') {
      calculatedDiscount = (_planAmount * discountVal) / 100;
    } else {
      calculatedDiscount = discountVal;
    }

    final total = _planAmount - calculatedDiscount + admission;
    final due = total - paid;
    return due < 0 ? 0.0 : due;
  }

  String _formatCurrency(double val) {
    final formatter = NumberFormat('#,##,###');
    return '₹${formatter.format(val.toInt())}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final initial = isStartDate ? _planStartDate : (_paymentDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primaryTeal),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _planStartDate = picked;
        } else {
          _paymentDate = picked;
        }
      });
    }
  }

  void _onPlanChanged(String? val) {
    if (val != null) {
      final match = _plans.firstWhere((p) => p['name'] == val);
      setState(() {
        _selectedPlan = val;
        _planAmount = match['amount'] as double;
        _durationMonths = match['months'] as int;
      });
    }
  }

  void _saveRenew() {
    final paid = double.tryParse(_paidAmountCtrl.text.trim()) ?? 0.0;
    final discountVal = double.tryParse(_discountCtrl.text.trim()) ?? 0.0;
    final admission = double.tryParse(_admissionFeesCtrl.text.trim()) ?? 0.0;

    double calculatedDiscount = 0.0;
    if (_discountType == 'Percent') {
      calculatedDiscount = (_planAmount * discountVal) / 100;
    } else {
      calculatedDiscount = discountVal;
    }

    // Compute new expiry date
    final newExpiry = DateTime(
      _planStartDate.year,
      _planStartDate.month + _durationMonths,
      _planStartDate.day,
    );

    final currentMember = widget.member;
    final updatedPaid = currentMember.amountPaid + paid;
    final updatedDues = _dueAmount;

    List<PaymentRecord> updatedHistory = List<PaymentRecord>.from(currentMember.paymentHistory);
    if (paid > 0) {
      updatedHistory.insert(
        0,
        PaymentRecord(
          id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
          date: _paymentDate ?? DateTime.now(),
          amount: paid,
          paymentMethod: _paymentMethod,
          notes: _commentsCtrl.text.trim().isNotEmpty ? _commentsCtrl.text.trim() : null,
        ),
      );
    }

    final updatedMember = currentMember.copyWith(
      planName: _selectedPlan.split('(').first.trim(),
      planAmount: _planAmount,
      amountPaid: updatedPaid,
      duesAmount: updatedDues,
      expiryDate: newExpiry,
      status: MemberStatus.active,
      paymentReminder: _paymentReminder,
      discount: calculatedDiscount,
      discountType: _discountType,
      admissionFees: admission,
      paymentHistory: updatedHistory,
      isFrozen: false,
    );

    GymService().updateMember(updatedMember);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Plan renewed for ${widget.member.fullName}! Valid till ${_formatDate(newExpiry)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Renew Plan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Select Gym Plan Dropdown
                      _buildDropdownField(
                        label: 'Select Gym Plan',
                        icon: Icons.assignment_outlined,
                        value: _selectedPlan,
                        items: _plans.map((p) => p['name'] as String).toList(),
                        onChanged: _onPlanChanged,
                      ),
                      const SizedBox(height: 10),

                      // Plan Amount text
                      Text(
                        'Plan Amount: ${_formatCurrency(_planAmount)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Plan Start Date *
                      _buildDateField(
                        label: 'Plan Start Date *',
                        date: _planStartDate,
                        onTap: () => _pickDate(isStartDate: true),
                      ),
                      const SizedBox(height: 14),

                      // Payment Date
                      _buildDateField(
                        label: 'Payment Date',
                        date: _paymentDate,
                        onTap: () => _pickDate(isStartDate: false),
                      ),
                      const SizedBox(height: 14),

                      // Paid Amount
                      _buildInputField(
                        controller: _paidAmountCtrl,
                        label: 'Paid Amount',
                        icon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),

                      // Payment Method
                      _buildDropdownField(
                        label: 'Payment Method',
                        icon: Icons.credit_card_outlined,
                        value: _paymentMethod,
                        items: const ['Cash', 'UPI', 'Credit/Debit Card', 'Net Banking'],
                        onChanged: (val) {
                          if (val != null) setState(() => _paymentMethod = val);
                        },
                      ),
                      const SizedBox(height: 12),

                      // Due Amount text
                      Text(
                        'Due Amount: ${_formatCurrency(_dueAmount)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Payment reminder Card with Switch
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Payment reminder',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Choose a date and time.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _paymentReminder,
                              activeColor: AppColors.primaryTeal,
                              onChanged: (val) => setState(() => _paymentReminder = val),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Comments
                      _buildInputField(
                        controller: _commentsCtrl,
                        label: 'Comments',
                        icon: Icons.chat_bubble_outline,
                      ),
                      const SizedBox(height: 14),

                      // Discount in Plan:
                      Row(
                        children: [
                          const Icon(Icons.tune, color: AppColors.primaryTeal, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Discount in Plan:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Radio<String>(
                            value: 'Percent',
                            groupValue: _discountType,
                            activeColor: AppColors.primaryTeal,
                            onChanged: (val) => setState(() => _discountType = val!),
                          ),
                          const Text('Percent', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 12),
                          Radio<String>(
                            value: 'Amount',
                            groupValue: _discountType,
                            activeColor: AppColors.primaryTeal,
                            onChanged: (val) => setState(() => _discountType = val!),
                          ),
                          const Text('Amount', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Discount Input
                      _buildInputField(
                        controller: _discountCtrl,
                        label: 'Discount',
                        icon: Icons.local_offer_outlined,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),

                      // Admission Fees Input
                      _buildInputField(
                        controller: _admissionFeesCtrl,
                        label: 'Admission Fees',
                        icon: Icons.fitness_center,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Sticky Bottom Save Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: SafeArea(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: _saveRenew,
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: AppColors.primaryTeal, size: 20),
            const SizedBox(width: 10),
            Text(
              date != null ? _formatDate(date) : label,
              style: TextStyle(
                fontSize: 14,
                color: date != null ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                fontWeight: date != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryTeal, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryTeal, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.contains(value) ? value : items.first,
                isExpanded: true,
                items: items
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item, style: const TextStyle(fontSize: 14, color: Color(0xFF111827))),
                        ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
