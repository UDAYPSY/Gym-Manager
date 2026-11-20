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
