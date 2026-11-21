import 'dart:async';
import '../models/gym_models.dart';

class GymService {
  static final GymService _instance = GymService._internal();
  factory GymService() => _instance;
  GymService._internal();

  final List<GymMember> _members = [];
  final BranchSettings _settings = BranchSettings();

  final _membersCtrl = StreamController<List<GymMember>>.broadcast();
  final _settingsCtrl = StreamController<BranchSettings>.broadcast();
  final _notificationCountCtrl = StreamController<int>.broadcast();

  int _notificationCount = 3; // Initial badge count matching screenshot

  Stream<List<GymMember>> get membersStream => _membersCtrl.stream;
  Stream<BranchSettings> get settingsStream => _settingsCtrl.stream;
  Stream<int> get notificationCountStream => _notificationCountCtrl.stream;

  List<GymMember> get members => List.unmodifiable(_members);
  BranchSettings get settings => _settings;
  int get notificationCount => _notificationCount;

  void addMember(GymMember member) {
    _members.add(member);
    _membersCtrl.add(List.unmodifiable(_members));
  }

  void updateMember(GymMember member) {
    final index = _members.indexWhere((m) => m.id == member.id);
    if (index != -1) {
      _members[index] = member;
      _membersCtrl.add(List.unmodifiable(_members));
    }
  }

  void deleteMember(String id) {
    _members.removeWhere((m) => m.id == id);
    _membersCtrl.add(List.unmodifiable(_members));
  }

  void clearAllMembers() {
    _members.clear();
    _membersCtrl.add(List.unmodifiable(_members));
  }

  void addPayment(String memberId, PaymentRecord payment) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      final current = _members[index];
      final newPaid = current.amountPaid + payment.amount;
      final newDues = (current.planAmount - current.discount + current.admissionFees - newPaid).clamp(0.0, double.infinity);
      final updatedHistory = List<PaymentRecord>.from(current.paymentHistory)..add(payment);

      _members[index] = current.copyWith(
        amountPaid: newPaid,
        duesAmount: newDues,
        paymentHistory: updatedHistory,
      );
      _membersCtrl.add(List.unmodifiable(_members));
    }
  }

  void deletePayment(String memberId, String paymentId) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      final current = _members[index];
      final payment = current.paymentHistory.firstWhere((p) => p.id == paymentId, orElse: () => PaymentRecord(id: '', date: DateTime.now(), amount: 0));
      final newPaid = (current.amountPaid - payment.amount).clamp(0.0, double.infinity);
      final newDues = (current.planAmount - current.discount + current.admissionFees - newPaid).clamp(0.0, double.infinity);
      final updatedHistory = current.paymentHistory.where((p) => p.id != paymentId).toList();

      _members[index] = current.copyWith(
        amountPaid: newPaid,
        duesAmount: newDues,
        paymentHistory: updatedHistory,
      );
      _membersCtrl.add(List.unmodifiable(_members));
    }
  }

  void togglePaymentReminder(String memberId, bool reminder) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      _members[index] = _members[index].copyWith(paymentReminder: reminder);
      _membersCtrl.add(List.unmodifiable(_members));
    }
  }

  void recordAttendance(String memberId, {required String checkInTime, String? checkOutTime}) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      final current = _members[index];
      final newRecord = AttendanceRecord(
        id: 'att_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
      );
      final updatedHistory = List<AttendanceRecord>.from(current.attendanceHistory)..insert(0, newRecord);
      _members[index] = current.copyWith(attendanceHistory: updatedHistory);
      _membersCtrl.add(List.unmodifiable(_members));
    }
  }

  void updateBiometricStatus(String memberId, {required String status, String? biometricId}) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      _members[index] = _members[index].copyWith(
        biometricStatus: status,
        biometricId: biometricId,
      );
      _membersCtrl.add(List.unmodifiable(_members));
    }
  }

  void toggleFreeze(String memberId, {bool? freeze}) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      final current = _members[index];
      final newFreeze = freeze ?? !current.isFrozen;
      _members[index] = current.copyWith(isFrozen: newFreeze);
      _membersCtrl.add(List.unmodifiable(_members));
    }
  }

  void toggleBlock(String memberId) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      final current = _members[index];
      final newStatus = current.status == MemberStatus.blocked ? MemberStatus.active : MemberStatus.blocked;
      _members[index] = current.copyWith(status: newStatus);
      _membersCtrl.add(List.unmodifiable(_members));
    }
  }

  void renewPlan(String memberId, {required String newPlanName, required double newPlanAmount, required int durationMonths}) {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index != -1) {
      final current = _members[index];
      final baseDate = current.isExpired ? DateTime.now() : current.expiryDate;
      final newExpiry = DateTime(baseDate.year, baseDate.month + durationMonths, baseDate.day);
      final newDue = current.duesAmount + newPlanAmount;
      _members[index] = current.copyWith(
        planName: newPlanName,
        planAmount: newPlanAmount,
        expiryDate: newExpiry,
        duesAmount: newDue,
        status: MemberStatus.active,
      );
      _membersCtrl.add(List.unmodifiable(_members));
    }
  }

  void setCurrency(String symbol, String code) {
    _settings.currencySymbol = symbol;
    _settings.currencyCode = code;
    _settingsCtrl.add(_settings);
  }

  void setNotificationCount(int count) {
    _notificationCount = count;
    _notificationCountCtrl.add(_notificationCount);
  }
}
