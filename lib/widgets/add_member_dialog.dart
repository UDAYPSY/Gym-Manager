import 'package:flutter/material.dart';
import '../services/gym_service.dart';
import '../models/gym_models.dart';
import '../constants/app_colors.dart';

class AddMemberDialog extends StatefulWidget {
  const AddMemberDialog({Key? key}) : super(key: key);

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _memberIdCtrl = TextEditingController();
  final _amountPaidCtrl = TextEditingController(text: '1500');
  final _duesCtrl = TextEditingController(text: '0');

  String _gender = 'Male';
  String _batch = 'Morning';
  String _selectedPlan = '1 Month Fitness';
  int _planDurationMonths = 1;

  final List<String> _plans = [
    '1 Month Fitness',
    '3 Months Transformation',
    '6 Months Pro Athlete',
    '1 Year VIP All-Access',
  ];

  final List<String> _batches = ['Morning', 'Evening', 'General Day', '24/7 Access'];

  @override
  void initState() {
    super.initState();
    final count = GymService().members.length + 1;
    _memberIdCtrl.text = 'M-${count.toString().padLeft(3, '0')}';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _memberIdCtrl.dispose();
    _amountPaidCtrl.dispose();
    _duesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 480,
        ),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryTeal,
                        radius: 18,
                        child: Icon(Icons.person_add, color: Colors.white, size: 20),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Add New Member',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      const Text('Full Name *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          hintText: 'Enter member full name',
                          prefixIcon: const Icon(Icons.person_outline, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter member name' : null,
                      ),
                      const SizedBox(height: 14),

                      // Mobile Number & Member ID
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Mobile Phone *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _phoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: '10-digit mobile',
                                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  validator: (val) => (val == null || val.trim().length < 6) ? 'Enter valid phone' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Member ID', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _memberIdCtrl,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Gender Selection
                      const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(
                        children: ['Male', 'Female', 'Other'].map((g) {
                          final selected = _gender == g;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(g),
                              selected: selected,
                              selectedColor: AppColors.primaryTeal.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: selected ? AppColors.primaryTeal : AppColors.textBlack,
                                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (_) => setState(() => _gender = g),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Membership Plan
                      const Text('Membership Plan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedPlan,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: _plans.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedPlan = val;
                              if (val.contains('1 Month')) {
                                _planDurationMonths = 1;
                                _amountPaidCtrl.text = '1500';
                              } else if (val.contains('3 Months')) {
                                _planDurationMonths = 3;
                                _amountPaidCtrl.text = '4000';
                              } else if (val.contains('6 Months')) {
                                _planDurationMonths = 6;
                                _amountPaidCtrl.text = '7500';
                              } else {
                                _planDurationMonths = 12;
                                _amountPaidCtrl.text = '12000';
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      // Batch
                      const Text('Gym Batch / Slot', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _batch,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: _batches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                        onChanged: (val) => setState(() => _batch = val ?? 'Morning'),
                      ),
                      const SizedBox(height: 14),

                      // Fee & Dues
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Amount Paid', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _amountPaidCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Pending Dues', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _duesCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textGray)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        final now = DateTime.now();
                        final expiry = DateTime(now.year, now.month + _planDurationMonths, now.day);
                        final newMember = GymMember(
                          id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
                          memberId: _memberIdCtrl.text.trim().isNotEmpty ? _memberIdCtrl.text.trim() : 'M-101',
                          fullName: _nameCtrl.text.trim(),
                          phone: _phoneCtrl.text.trim(),
                          gender: _gender,
                          joinedDate: now,
                          expiryDate: expiry,
                          planName: _selectedPlan,
                          amountPaid: double.tryParse(_amountPaidCtrl.text) ?? 0.0,
                          duesAmount: double.tryParse(_duesCtrl.text) ?? 0.0,
                          status: MemberStatus.active,
                          batch: _batch,
                        );

                        GymService().addMember(newMember);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Member "${newMember.fullName}" successfully registered!'),
                            backgroundColor: AppColors.primaryTeal,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const Text('Save Member', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
