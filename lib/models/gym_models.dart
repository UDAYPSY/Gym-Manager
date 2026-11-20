import 'dart:convert';

enum MemberStatus { active, expired, pending, blocked }

class GymMember {
  final String id;
  final String memberId; // e.g. "3"
  final String fullName;
  final String phone;
  final String countryCode; // e.g. "+91"
  final String gender;
  final DateTime joinedDate;
  final DateTime expiryDate;
  final String planName;
  final double planAmount;
  final double amountPaid;
  final double duesAmount;
  final MemberStatus status;
  final String? batch; // Morning, Evening, etc.
  final String? paymentMethod; // Cash, UPI, Card, Net Banking
  final DateTime? paymentDate;
  final bool paymentReminder;
  final String? comments;
  final String discountType; // "Percent" or "Amount"
  final double discount;
  final double admissionFees;
  final String? email;
  final String? dob;
  final String? address;
  final String? notes;
  final String? photoBase64;

  GymMember({
    required this.id,
    required this.memberId,
    required this.fullName,
    required this.phone,
    this.countryCode = '+91',
    this.gender = 'Male',
    required this.joinedDate,
    required this.expiryDate,
    this.planName = '6 month plan (20000)',
    this.planAmount = 20000.0,
    this.amountPaid = 0.0,
    this.duesAmount = 20000.0,
    this.status = MemberStatus.active,
    this.batch = 'No Batch Found',
    this.paymentMethod = 'Cash',
    this.paymentDate,
    this.paymentReminder = false,
    this.comments,
    this.discountType = 'Percent',
    this.discount = 0.0,
    this.admissionFees = 0.0,
    this.email,
    this.dob,
    this.address,
    this.notes,
    this.photoBase64,
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
    String? countryCode,
    String? gender,
    DateTime? joinedDate,
    DateTime? expiryDate,
    String? planName,
    double? planAmount,
    double? amountPaid,
    double? duesAmount,
    MemberStatus? status,
    String? batch,
    String? paymentMethod,
    DateTime? paymentDate,
    bool? paymentReminder,
    String? comments,
    String? discountType,
    double? discount,
    double? admissionFees,
    String? email,
    String? dob,
    String? address,
    String? notes,
    String? photoBase64,
  }) {
    return GymMember(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      gender: gender ?? this.gender,
      joinedDate: joinedDate ?? this.joinedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      planName: planName ?? this.planName,
      planAmount: planAmount ?? this.planAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      duesAmount: duesAmount ?? this.duesAmount,
      status: status ?? this.status,
      batch: batch ?? this.batch,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentReminder: paymentReminder ?? this.paymentReminder,
      comments: comments ?? this.comments,
      discountType: discountType ?? this.discountType,
      discount: discount ?? this.discount,
      admissionFees: admissionFees ?? this.admissionFees,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      photoBase64: photoBase64 ?? this.photoBase64,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'memberId': memberId,
    'fullName': fullName,
    'phone': phone,
    'countryCode': countryCode,
    'gender': gender,
    'joinedDate': joinedDate.toIso8601String(),
    'expiryDate': expiryDate.toIso8601String(),
    'planName': planName,
    'planAmount': planAmount,
    'amountPaid': amountPaid,
    'duesAmount': duesAmount,
    'status': status.name,
    'batch': batch,
    'paymentMethod': paymentMethod,
    'paymentDate': paymentDate?.toIso8601String(),
    'paymentReminder': paymentReminder,
    'comments': comments,
    'discountType': discountType,
    'discount': discount,
    'admissionFees': admissionFees,
    'email': email,
    'dob': dob,
    'address': address,
    'notes': notes,
    'photoBase64': photoBase64,
  };

  factory GymMember.fromJson(Map<String, dynamic> json) {
    return GymMember(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '3',
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '+91',
      gender: json['gender'] as String? ?? 'Male',
      joinedDate: json['joinedDate'] != null ? DateTime.parse(json['joinedDate'] as String) : DateTime.now(),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate'] as String) : DateTime.now().add(const Duration(days: 180)),
      planName: json['planName'] as String? ?? '6 month plan (20000)',
      planAmount: (json['planAmount'] as num?)?.toDouble() ?? 20000.0,
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
      duesAmount: (json['duesAmount'] as num?)?.toDouble() ?? 20000.0,
      status: MemberStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MemberStatus.active,
      ),
      batch: json['batch'] as String? ?? 'No Batch Found',
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
      paymentDate: json['paymentDate'] != null ? DateTime.parse(json['paymentDate'] as String) : null,
      paymentReminder: json['paymentReminder'] as bool? ?? false,
      comments: json['comments'] as String?,
      discountType: json['discountType'] as String? ?? 'Percent',
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      admissionFees: (json['admissionFees'] as num?)?.toDouble() ?? 0.0,
      email: json['email'] as String?,
      dob: json['dob'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      photoBase64: json['photoBase64'] as String?,
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
