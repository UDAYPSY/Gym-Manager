import 'dart:convert';

enum MemberStatus { active, expired, pending, blocked }

class GymMember {
  final String id;
  final String memberId; // e.g. M-101
  final String fullName;
  final String phone;
  final String gender;
  final DateTime joinedDate;
  final DateTime expiryDate;
  final String planName;
  final double amountPaid;
  final double duesAmount;
  final MemberStatus status;
  final String? batch; // Morning, Evening, etc.
  final String? notes;

  GymMember({
    required this.id,
    required this.memberId,
    required this.fullName,
    required this.phone,
    this.gender = 'Male',
    required this.joinedDate,
    required this.expiryDate,
    this.planName = 'General Fitness (1 Month)',
    this.amountPaid = 1500.0,
    this.duesAmount = 0.0,
    this.status = MemberStatus.active,
    this.batch = 'Morning',
    this.notes,
  });

  bool get isExpired => expiryDate.isBefore(DateTime.now());
  bool get hasDues => duesAmount > 0;
  int get daysRemaining {
    final diff = expiryDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  GymMember copyWith({
    String? id,
    String? memberId,
    String? fullName,
    String? phone,
    String? gender,
    DateTime? joinedDate,
    DateTime? expiryDate,
    String? planName,
    double? amountPaid,
    double? duesAmount,
    MemberStatus? status,
    String? batch,
    String? notes,
  }) {
    return GymMember(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      joinedDate: joinedDate ?? this.joinedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      planName: planName ?? this.planName,
      amountPaid: amountPaid ?? this.amountPaid,
      duesAmount: duesAmount ?? this.duesAmount,
      status: status ?? this.status,
      batch: batch ?? this.batch,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'memberId': memberId,
    'fullName': fullName,
    'phone': phone,
    'gender': gender,
    'joinedDate': joinedDate.toIso8601String(),
    'expiryDate': expiryDate.toIso8601String(),
    'planName': planName,
    'amountPaid': amountPaid,
    'duesAmount': duesAmount,
    'status': status.name,
    'batch': batch,
    'notes': notes,
  };

  factory GymMember.fromJson(Map<String, dynamic> json) {
    return GymMember(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String? ?? 'M-${DateTime.now().millisecondsSinceEpoch % 10000}',
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      gender: json['gender'] as String? ?? 'Male',
      joinedDate: json['joinedDate'] != null ? DateTime.parse(json['joinedDate'] as String) : DateTime.now(),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate'] as String) : DateTime.now().add(const Duration(days: 30)),
      planName: json['planName'] as String? ?? 'Monthly Fitness',
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
      duesAmount: (json['duesAmount'] as num?)?.toDouble() ?? 0.0,
      status: MemberStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MemberStatus.active,
      ),
      batch: json['batch'] as String? ?? 'Morning',
      notes: json['notes'] as String?,
    );
  }
}

class MembershipPlan {
  final String id;
  final String name;
  final int durationMonths;
  final double price;

  const MembershipPlan({
    required this.id,
    required this.name,
    required this.durationMonths,
    required this.price,
  });
}

class BranchSettings {
  String gymName;
  String? currencySymbol;
  String? currencyCode;
  String phone;
  String address;

  BranchSettings({
    this.gymName = 'Gym Manager',
    this.currencySymbol,
    this.currencyCode,
    this.phone = '',
    this.address = '',
  });

  bool get hasSelectedCurrency => currencySymbol != null && currencySymbol!.isNotEmpty;
}
