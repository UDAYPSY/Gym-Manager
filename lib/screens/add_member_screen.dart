import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/gym_service.dart';
import '../models/gym_models.dart';
import '../constants/app_colors.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({Key? key}) : super(key: key);

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _memberIdCtrl = TextEditingController();
  final _paidAmountCtrl = TextEditingController(text: '0');
  final _commentsCtrl = TextEditingController();
  final _discountCtrl = TextEditingController(text: '0');
  final _admissionFeesCtrl = TextEditingController(text: '0');
  final _emailCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Basic Details State
  String _gender = 'Male';
  String _countryCode = '+91';
  String _batch = 'No Batch Found';

  // Plan Details State
  String _selectedPlan = '6 month plan (20000)';
  double _planAmount = 20000.0;
  DateTime _joiningDate = DateTime.now();
  DateTime _paymentDate = DateTime.now();
  String _paymentMethod = 'Select Payment Method';
  bool _paymentReminder = false;
  String _discountType = 'Percent'; // "Percent" or "Amount"

  final List<Map<String, dynamic>> _availablePlans = [
    {'name': '1 month plan (4000)', 'amount': 4000.0, 'months': 1},
    {'name': '3 month plan (11000)', 'amount': 11000.0, 'months': 3},
    {'name': '6 month plan (20000)', 'amount': 20000.0, 'months': 6},
    {'name': '1 year plan (35000)', 'amount': 35000.0, 'months': 12},
  ];

  final List<String> _batches = [
    'No Batch Found',
    'Morning Batch (6:00 AM - 10:00 AM)',
    'Evening Batch (5:00 PM - 10:00 PM)',
    'General Slot (10:00 AM - 5:00 PM)',
    '24/7 All-Access',
  ];

  final List<String> _paymentMethods = [
    'Select Payment Method',
    'Cash',
    'UPI (GPay / PhonePe / Paytm)',
    'Credit / Debit Card',
    'Net Banking',
  ];

  @override
  void initState() {
    super.initState();
    final count = GymService().members.length + 1;
    _memberIdCtrl.text = '$count';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _memberIdCtrl.dispose();
    _paidAmountCtrl.dispose();
    _commentsCtrl.dispose();
    _discountCtrl.dispose();
    _admissionFeesCtrl.dispose();
    _emailCtrl.dispose();
    _dobCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _dueAmount {
    final paid = double.tryParse(_paidAmountCtrl.text) ?? 0.0;
    final admission = double.tryParse(_admissionFeesCtrl.text) ?? 0.0;
    final discountVal = double.tryParse(_discountCtrl.text) ?? 0.0;

    double actualDiscount = 0.0;
    if (_discountType == 'Percent') {
      actualDiscount = (_planAmount * discountVal) / 100.0;
    } else {
      actualDiscount = discountVal;
    }

    final total = (_planAmount + admission) - actualDiscount;
    final due = total - paid;
    return due < 0 ? 0 : due;
  }

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryTeal,
              onPrimary: Colors.white,
              onSurface: AppColors.textBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = GymService().settings.currencySymbol ?? '₹';
    final numberFormat = NumberFormat('#,##,###');

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Member',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: 'Add Member Settings',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Member registration settings'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  children: [
                    // ========================================================
                    // CARD 1: Basic Member Profile
                    // ========================================================
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Centered Profile Avatar with Camera Icon
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD3D8DF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 72,
                                    color: Colors.white,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Select Photo from Camera / Gallery')),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryTeal,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Name Field
                          _buildCustomInput(
                            icon: Icons.person,
                            child: TextFormField(
                              controller: _nameCtrl,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Name *',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              validator: (val) =>
                                  (val == null || val.trim().isEmpty) ? 'Please enter member name' : null,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Gender Radio Row
                          Row(
                            children: [
                              const Icon(Icons.person, color: AppColors.primaryTeal, size: 22),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => setState(() => _gender = 'Male'),
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Male',
                                      groupValue: _gender,
                                      activeColor: AppColors.primaryTeal,
                                      visualDensity: VisualDensity.compact,
                                      onChanged: (val) => setState(() => _gender = val!),
                                    ),
                                    const Text('Male', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () => setState(() => _gender = 'Female'),
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Female',
                                      groupValue: _gender,
                                      activeColor: AppColors.primaryTeal,
                                      visualDensity: VisualDensity.compact,
                                      onChanged: (val) => setState(() => _gender = val!),
                                    ),
                                    const Text('Female', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Phone Number Field (Split Country Code & Number)
                          Row(
                            children: [
                              Container(
                                height: 46,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFD1D5DB)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🇮🇳 +91', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                    const SizedBox(width: 4),
                                    Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey.shade600),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 46,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFD1D5DB)),
                                  ),
                                  child: Center(
                                    child: TextFormField(
                                      controller: _phoneCtrl,
                                      keyboardType: TextInputType.phone,
                                      style: const TextStyle(fontSize: 14),
                                      decoration: const InputDecoration(
                                        hintText: 'Enter mobile number',
                                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                      validator: (val) => (val == null || val.trim().length < 6)
                                          ? 'Please enter valid phone'
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Membership ID Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOutlineLabeledInput(
                                label: 'Membership ID',
                                icon: Icons.badge_outlined,
                                iconColor: const Color(0xFF22C55E),
                                child: TextFormField(
                                  controller: _memberIdCtrl,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Membership ID is available',
                                style: TextStyle(
                                  color: Color(0xFF22C55E),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Batch / Group Class Field
                          _buildOutlineLabeledInput(
                            label: 'Batch / Group Class',
                            icon: Icons.groups,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _batch,
                                style: const TextStyle(color: Colors.black87, fontSize: 14),
                                items: _batches
                                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                                    .toList(),
                                onChanged: (val) => setState(() => _batch = val ?? _batch),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ========================================================
                    // CARD 2: Plan Details
                    // ========================================================
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Plan Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Select Gym Plan
                          _buildOutlineLabeledInput(
                            label: 'Select Gym Plan',
                            icon: Icons.assignment,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedPlan,
                                style: const TextStyle(color: Colors.black87, fontSize: 14),
                                items: _availablePlans.map((p) {
                                  final name = p['name'] as String;
                                  return DropdownMenuItem(value: name, child: Text(name));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    final match = _availablePlans.firstWhere((p) => p['name'] == val);
                                    setState(() {
                                      _selectedPlan = val;
                                      _planAmount = match['amount'] as double;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Plan Amount Display
                          Text(
                            'Plan Amount: $currency${numberFormat.format(_planAmount)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Select Joining Date
                          GestureDetector(
                            onTap: () {
                              _pickDate(
                                context: context,
                                initialDate: _joiningDate,
                                onPicked: (d) => setState(() => _joiningDate = d),
                              );
                            },
                            child: _buildCustomInput(
                              icon: Icons.calendar_today_outlined,
                              child: Text(
                                DateFormat('dd MMM yyyy').format(_joiningDate),
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Payment Date
                          GestureDetector(
                            onTap: () {
                              _pickDate(
                                context: context,
                                initialDate: _paymentDate,
                                onPicked: (d) => setState(() => _paymentDate = d),
                              );
                            },
                            child: _buildCustomInput(
                              icon: Icons.calendar_today_outlined,
                              child: Text(
                                DateFormat('dd MMM yyyy').format(_paymentDate),
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Paid Amount
                          _buildCustomInput(
                            icon: Icons.payments_outlined,
                            child: TextFormField(
                              controller: _paidAmountCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Paid Amount',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Payment Method
                          _buildOutlineLabeledInput(
                            label: 'Payment Method',
                            icon: Icons.credit_card,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _paymentMethod,
                                style: const TextStyle(color: Colors.black87, fontSize: 14),
                                items: _paymentMethods
                                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                    .toList(),
                                onChanged: (val) => setState(() => _paymentMethod = val ?? _paymentMethod),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Due Amount Display
                          Text(
                            'Due Amount: $currency${numberFormat.format(_dueAmount)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _dueAmount > 0 ? Colors.red.shade700 : Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Payment reminder box
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
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
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textBlack,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Choose a date and time.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
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
                          const SizedBox(height: 12),

                          // Comments Field
                          _buildCustomInput(
                            icon: Icons.chat_bubble_outline,
                            child: TextFormField(
                              controller: _commentsCtrl,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Comments',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Discount in Plan Section
                          Row(
                            children: [
                              const Icon(Icons.tune, color: AppColors.primaryTeal, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Discount in Plan:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textBlack,
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => setState(() => _discountType = 'Percent'),
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Percent',
                                      groupValue: _discountType,
                                      activeColor: AppColors.primaryTeal,
                                      visualDensity: VisualDensity.compact,
                                      onChanged: (val) => setState(() => _discountType = val!),
                                    ),
                                    const Text('Percent', style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => setState(() => _discountType = 'Amount'),
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Amount',
                                      groupValue: _discountType,
                                      activeColor: AppColors.primaryTeal,
                                      visualDensity: VisualDensity.compact,
                                      onChanged: (val) => setState(() => _discountType = val!),
                                    ),
                                    const Text('Amount', style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Discount Field
                          _buildCustomInput(
                            icon: Icons.verified_outlined,
                            child: TextFormField(
                              controller: _discountCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Discount',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Admission Fees Field
                          _buildCustomInput(
                            icon: Icons.fitness_center,
                            child: TextFormField(
                              controller: _admissionFeesCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Admission Fees',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ========================================================
                    // CARD 3: Member Details
                    // ========================================================
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Member Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Email
                          _buildCustomInput(
                            icon: Icons.mail_outline,
                            child: TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Date of Birth
                          GestureDetector(
                            onTap: () {
                              _pickDate(
                                context: context,
                                initialDate: DateTime(2000, 1, 1),
                                onPicked: (d) => setState(() => _dobCtrl.text = DateFormat('dd/MM/yyyy').format(d)),
                              );
                            },
                            child: _buildCustomInput(
                              icon: Icons.cake_outlined,
                              child: TextFormField(
                                controller: _dobCtrl,
                                enabled: false,
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                                decoration: const InputDecoration(
                                  hintText: 'Date of Birth',
                                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Address
                          _buildCustomInput(
                            icon: Icons.home_outlined,
                            child: TextFormField(
                              controller: _addressCtrl,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Address',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Notes
                          _buildCustomInput(
                            icon: Icons.assignment_outlined,
                            child: TextFormField(
                              controller: _notesCtrl,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Notes',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ========================================================
            // STICKY BOTTOM SAVE BUTTON
            // ========================================================
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _saveMember,
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveMember() {
    if (_formKey.currentState?.validate() ?? false) {
      final now = DateTime.now();
      // Calculate expiry date based on plan
      final match = _availablePlans.firstWhere(
        (p) => p['name'] == _selectedPlan,
        orElse: () => {'months': 6},
      );
      final months = match['months'] as int;
      final expiry = DateTime(_joiningDate.year, _joiningDate.month + months, _joiningDate.day);

      final paid = double.tryParse(_paidAmountCtrl.text) ?? 0.0;
      final discount = double.tryParse(_discountCtrl.text) ?? 0.0;
      final admission = double.tryParse(_admissionFeesCtrl.text) ?? 0.0;

      final newMember = GymMember(
        id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
        memberId: _memberIdCtrl.text.trim().isNotEmpty ? _memberIdCtrl.text.trim() : '3',
        fullName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        countryCode: _countryCode,
        gender: _gender,
        joinedDate: _joiningDate,
        expiryDate: expiry,
        planName: _selectedPlan,
        planAmount: _planAmount,
        amountPaid: paid,
        duesAmount: _dueAmount,
        status: MemberStatus.active,
        batch: _batch,
        paymentMethod: _paymentMethod,
        paymentDate: _paymentDate,
        paymentReminder: _paymentReminder,
        comments: _commentsCtrl.text.trim().isNotEmpty ? _commentsCtrl.text.trim() : null,
        discountType: _discountType,
        discount: discount,
        admissionFees: admission,
        email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
        dob: _dobCtrl.text.trim().isNotEmpty ? _dobCtrl.text.trim() : null,
        address: _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : null,
        notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      );

      GymService().addMember(newMember);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Member "${newMember.fullName}" successfully added!'),
          backgroundColor: AppColors.primaryTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCustomInput({
    required IconData icon,
    required Widget child,
    Color? iconColor,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? AppColors.primaryTeal, size: 22),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildOutlineLabeledInput({
    required String label,
    required IconData icon,
    required Widget child,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(icon, color: iconColor ?? AppColors.primaryTeal, size: 22),
              const SizedBox(width: 10),
              Expanded(child: child),
            ],
          ),
        ],
      ),
    );
  }
}
