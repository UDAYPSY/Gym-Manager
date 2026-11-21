import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/gym_service.dart';
import '../models/gym_models.dart';
import '../constants/app_colors.dart';
import '../widgets/add_member_dialog.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/currency_picker_dialog.dart';
import 'add_member_screen.dart';
import 'member_detail_screen.dart';
import '../utils/member_actions.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({Key? key}) : super(key: key);

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isMemberIdMode = false;

  String _filterStatus = 'All';
  String _filterAttention = 'Needs Attention First';
  String _filterPlan = 'All Plans';
  String _filterBatch = 'Select Batch';
  String _filterGender = 'Select Gender';

  static const List<String> statusFilterOptions = [
    'All',
    'Active',
    'Inactive',
    'Frozen Membership',
    'Unpaid',
    'Paid',
    'Expiring in 1-3 Days',
    'Expiring in 4-7 Days',
    'Expiring in 8-15 Days',
    'Expired 1-3 Days Ago',
    'Expired 4-7 Days Ago',
    'Birthday Today',
    'Blocked',
    'Expiring Today',
    'Biometric Registered',
    'PT Plan Expiring Today',
    'PT Plan Expiring (1–3d)',
    'PT Plan Expiring (4–7d)',
    'PT Plan Expiring (8–15d)',
    'Active PT Plans',
    'Expired PT Plans',
    'Total PT Plans',
    'Include blocked & deleted',
  ];

  static const List<String> attentionFilterOptions = [
    'Needs Attention First',
    'Newly Joined Members First',
    'Highest Due Amount First',
    'Expiring Membership First',
    'Longest Membership Validity First',
    'Newly Purchased Membership First',
    'Recently Updated Members First',
  ];

  static const List<String> genderFilterOptions = [
    'Select Gender',
    'Male',
    'Female',
    'Other',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddMemberModal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const AddMemberScreen()),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const CurrencyPickerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gymService = GymService();

    return StreamBuilder<List<GymMember>>(
      stream: gymService.membersStream,
      initialData: gymService.members,
      builder: (context, memberSnapshot) {
        final allMembers = memberSnapshot.data ?? [];

        // Filter Logic
        final filteredMembers = allMembers.where((m) {
          final query = _searchCtrl.text.trim().toLowerCase();
          if (query.isNotEmpty) {
            if (_isMemberIdMode) {
              if (!m.memberId.toLowerCase().contains(query)) return false;
            } else {
              if (!m.phone.toLowerCase().contains(query) &&
                  !m.fullName.toLowerCase().contains(query)) {
                return false;
              }
            }
          }

          // Status filter matching the 23 options
          if (_filterStatus == 'Active' && (m.status != MemberStatus.active || m.isExpired)) return false;
          if (_filterStatus == 'Inactive' && m.status == MemberStatus.active && !m.isExpired) return false;
          if (_filterStatus == 'Frozen Membership' && !(m.notes?.toLowerCase().contains('frozen') ?? false)) return false;
          if (_filterStatus == 'Unpaid' && !m.hasDues) return false;
          if (_filterStatus == 'Paid' && (m.hasDues || m.amountPaid <= 0)) return false;
          if (_filterStatus == 'Expiring in 1-3 Days' && (m.daysRemaining < 1 || m.daysRemaining > 3 || m.isExpired)) return false;
          if (_filterStatus == 'Expiring in 4-7 Days' && (m.daysRemaining < 4 || m.daysRemaining > 7 || m.isExpired)) return false;
          if (_filterStatus == 'Expiring in 8-15 Days' && (m.daysRemaining < 8 || m.daysRemaining > 15 || m.isExpired)) return false;
          if (_filterStatus == 'Expired 1-3 Days Ago') {
            if (!m.isExpired) return false;
            final daysAgo = DateTime.now().difference(m.expiryDate).inDays;
            if (daysAgo < 1 || daysAgo > 3) return false;
          }
          if (_filterStatus == 'Expired 4-7 Days Ago') {
            if (!m.isExpired) return false;
            final daysAgo = DateTime.now().difference(m.expiryDate).inDays;
            if (daysAgo < 4 || daysAgo > 7) return false;
          }
          if (_filterStatus == 'Birthday Today') {
            if (m.dob == null || m.dob!.isEmpty) return false;
            final now = DateTime.now();
            final todayStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}';
            if (!m.dob!.startsWith(todayStr)) return false;
          }
          if (_filterStatus == 'Blocked' && m.status != MemberStatus.blocked) return false;
          if (_filterStatus == 'Expiring Today' && (m.daysRemaining != 0 || m.isExpired)) return false;
          if (_filterStatus == 'PT Plan Expiring Today' && (!m.planName.toLowerCase().contains('pt') || m.daysRemaining != 0 || m.isExpired)) return false;
          if (_filterStatus == 'PT Plan Expiring (1–3d)' && (!m.planName.toLowerCase().contains('pt') || m.daysRemaining < 1 || m.daysRemaining > 3 || m.isExpired)) return false;
          if (_filterStatus == 'PT Plan Expiring (4–7d)' && (!m.planName.toLowerCase().contains('pt') || m.daysRemaining < 4 || m.daysRemaining > 7 || m.isExpired)) return false;
          if (_filterStatus == 'PT Plan Expiring (8–15d)' && (!m.planName.toLowerCase().contains('pt') || m.daysRemaining < 8 || m.daysRemaining > 15 || m.isExpired)) return false;
          if (_filterStatus == 'Active PT Plans' && (!m.planName.toLowerCase().contains('pt') || m.isExpired)) return false;
          if (_filterStatus == 'Expired PT Plans' && (!m.planName.toLowerCase().contains('pt') || !m.isExpired)) return false;
          if (_filterStatus == 'Total PT Plans' && !m.planName.toLowerCase().contains('pt')) return false;
          if (_filterStatus != 'Include blocked & deleted' && _filterStatus != 'Blocked' && m.status == MemberStatus.blocked) return false;

          // Plan filter
          if (_filterPlan != 'All Plans' && !m.planName.toLowerCase().contains(_filterPlan.toLowerCase())) return false;

          // Batch filter
          if (_filterBatch != 'Select Batch' && m.batch != _filterBatch) return false;

          // Gender filter
          if (_filterGender != 'Select Gender' && m.gender.toLowerCase() != _filterGender.toLowerCase()) return false;

          return true;
        }).toList();

        // Sorting / Priority Logic
        filteredMembers.sort((a, b) {
          switch (_filterAttention) {
            case 'Newly Joined Members First':
              return b.joinedDate.compareTo(a.joinedDate);
            case 'Highest Due Amount First':
              return b.duesAmount.compareTo(a.duesAmount);
            case 'Expiring Membership First':
              return a.expiryDate.compareTo(b.expiryDate);
            case 'Longest Membership Validity First':
              return b.expiryDate.compareTo(a.expiryDate);
            case 'Newly Purchased Membership First':
              return (b.paymentDate ?? b.joinedDate).compareTo(a.paymentDate ?? a.joinedDate);
            case 'Recently Updated Members First':
              return b.id.compareTo(a.id);
            case 'Needs Attention First':
            default:
              final aScore = (a.hasDues ? 100 : 0) + (a.isExpired ? 50 : 0) + (30 - a.daysRemaining);
              final bScore = (b.hasDues ? 100 : 0) + (b.isExpired ? 50 : 0) + (30 - b.daysRemaining);
              return bScore.compareTo(aScore);
          }
        });

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: _buildAppDrawer(context),
          appBar: AppBar(
            backgroundColor: AppColors.primaryTeal,
            elevation: 0,
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            title: const Text(
              'Members',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            actions: [
              // Chat message icon with green count badge
              StreamBuilder<int>(
                stream: gymService.notificationCountStream,
                initialData: gymService.notificationCount,
                builder: (context, notifSnapshot) {
                  final count = notifSnapshot.data ?? 3;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
                        onPressed: () => _showNotificationsSheet(context),
                      ),
                      if (count > 0)
                        Positioned(
                          right: 8,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.badgeGreen,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Center(
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                tooltip: 'Bin / Deleted Members',
                onPressed: () => _showBinDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.white, size: 24),
                tooltip: 'Help & Guide',
                onPressed: () => _showHelpDialog(context),
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                color: AppColors.primaryTeal,
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(
                  children: [
                    // Search Input Box
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(fontSize: 14, color: AppColors.textBlack),
                                decoration: InputDecoration(
                                  hintText: _isMemberIdMode
                                      ? 'Search for "MembershipId"'
                                      : 'Search for "Name"',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() {}),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryTealLight,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                child: const Icon(Icons.search, color: Colors.white, size: 22),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // M ID Switch Container
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isMemberIdMode = !_isMemberIdMode;
                        });
                      },
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTealDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'M ID',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Compact Switch Visual
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 32,
                              height: 16,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: _isMemberIdMode
                                    ? AppColors.badgeGreen
                                    : Colors.grey.shade400,
                              ),
                              child: Align(
                                alignment: _isMemberIdMode
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              // Filter Chips Row
              _buildFilterChipsRow(context),

              // Main Body: Empty State or Member List
              Expanded(
                child: filteredMembers.isEmpty
                    ? _buildEmptyState(context)
                    : _buildMemberList(context, filteredMembers),
              ),

              // Currency Warning Notice Banner (pinned above navigation)
              StreamBuilder<BranchSettings>(
                stream: gymService.settingsStream,
                initialData: gymService.settings,
                builder: (context, settingsSnapshot) {
                  final settings = settingsSnapshot.data ?? gymService.settings;
                  if (settings.hasSelectedCurrency) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    width: double.infinity,
                    color: AppColors.warningBannerBg,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text('💰', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 6),
                            Text(
                              "You haven't selected a currency yet.",
                              style: TextStyle(
                                color: AppColors.warningBannerText,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _showCurrencyPicker(context),
                          child: const Text(
                            'Choose Currency',
                            style: TextStyle(
                              color: AppColors.linkBlue,
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddMemberModal(context),
            backgroundColor: AppColors.primaryTeal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            icon: const Icon(Icons.person_add, color: Colors.white, size: 20),
            label: const Text(
              'Add Member',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChipsRow(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: _filterStatus,
              onTap: () {
                FilterBottomSheet.show(
                  context,
                  options: statusFilterOptions,
                  selectedOption: _filterStatus,
                  onSelected: (val) => setState(() => _filterStatus = val),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: _filterAttention,
              onTap: () {
                FilterBottomSheet.show(
                  context,
                  options: attentionFilterOptions,
                  selectedOption: _filterAttention,
                  onSelected: (val) => setState(() => _filterAttention = val),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: _filterPlan,
              onTap: () {
                FilterBottomSheet.show(
                  context,
                  options: [
                    'All Plans',
                    '1 Month Fitness',
                    '3 Months Transformation',
                    '6 Months Pro Athlete',
                    '1 Year VIP All-Access',
                  ],
                  selectedOption: _filterPlan,
                  onSelected: (val) => setState(() => _filterPlan = val),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: _filterBatch,
              onTap: () {
                FilterBottomSheet.show(
                  context,
                  options: ['Select Batch', 'Morning', 'Evening', 'General Day', '24/7 Access'],
                  selectedOption: _filterBatch,
                  onSelected: (val) => setState(() => _filterBatch = val),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: _filterGender,
              onTap: () {
                FilterBottomSheet.show(
                  context,
                  options: genderFilterOptions,
                  selectedOption: _filterGender,
                  onSelected: (val) => setState(() => _filterGender = val),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.chipBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.chipBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textBlack,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: AppColors.textBlack,
            ),
          ],
        ),
      ),
    );
  }

  // Exact Match to User Screenshot Center Empty State
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No Members Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'You can add a new member by clicking\nthe button below',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1E1E1E),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'OR',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                elevation: 0,
              ),
              onPressed: () => _showAddMemberModal(context),
              child: const Text(
                'Add Member',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberList(BuildContext context, List<GymMember> members) {
    final currency = GymService().settings.currencySymbol ?? '₹';
    final numFormatter = NumberFormat('#,##,###');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final m = members[index];
        final expiryStr = DateFormat('dd MMM yyyy').format(m.expiryDate);
        final dueStr = '$currency${numFormatter.format(m.duesAmount.toInt())}';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: Stack(
            children: [
              // Top-Right Green Corner Accent (exact match to screenshot)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF43A047),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(24),
                    ),
                  ),
                ),
              ),
              // Bottom-Left Green Corner Accent (exact match to screenshot)
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF43A047),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      topRight: Radius.circular(24),
                    ),
                  ),
                ),
              ),

              // Main White Member Card
              Container(
                margin: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MemberDetailScreen(member: m),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Area: Avatar, Info Columns, Trash Icon
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar Circle
                              Container(
                                width: 54,
                                height: 54,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryTeal,
                                ),
                                alignment: Alignment.center,
                                child: m.photoBase64 != null && m.photoBase64!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.memory(
                                          base64Decode(m.photoBase64!),
                                          width: 54,
                                          height: 54,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Text(
                                        m.fullName.isNotEmpty ? m.fullName[0].toUpperCase() : 'M',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),

                              // Info Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Name:',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.primaryTeal,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      m.fullName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 6),

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
                                                m.memberId,
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
                                                'Mobile:',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF6B7280),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                '${m.countryCode} - ${m.phone}',
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
                                    const SizedBox(height: 6),

                                    // Plan Expiry & Due Amount Row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Plan Expiry:',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF6B7280),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                expiryStr,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2E7D32),
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
                                                'Due Amount:',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF6B7280),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                dueStr,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFD32F2F),
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

                              // Trash Icon
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF6B7280)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _confirmDeleteMember(context, m),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          const Divider(height: 1, thickness: 0.8, color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 8),

                          // Bottom Row: 6 Action Icons
                          Row(
                            children: [
                              Expanded(
                                child: _buildCardActionItem(
                                  icon: Icons.badge_outlined,
                                  label: 'ID Card',
                                  onTap: () => MemberActions.openIdCard(context, m),
                                ),
                              ),
                              Expanded(
                                child: _buildCardActionItem(
                                  icon: Icons.call_outlined,
                                  label: 'Call',
                                  onTap: () => MemberActions.makePhoneCall(context, m),
                                ),
                              ),
                              Expanded(
                                child: _buildCardActionItem(
                                  icon: Icons.chat_bubble_outline,
                                  label: 'Whatsapp',
                                  onTap: () => MemberActions.openWhatsApp(context, m),
                                ),
                              ),
                              Expanded(
                                child: _buildCardActionItem(
                                  icon: Icons.touch_app_outlined,
                                  label: 'Attendance',
                                  onTap: () => MemberActions.markAttendance(context, m),
                                ),
                              ),
                              Expanded(
                                child: _buildCardActionItem(
                                  icon: Icons.grid_view,
                                  label: 'Renew Plan',
                                  onTap: () => MemberActions.renewPlan(context, m),
                                ),
                              ),
                              Expanded(
                                child: _buildCardActionItem(
                                  icon: Icons.block_outlined,
                                  label: m.status == MemberStatus.blocked ? 'Unblock' : 'Block Member',
                                  onTap: () => MemberActions.blockMember(context, m),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: const Color(0xFF374151)),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showIdCardDialog(BuildContext context, GymMember member) =>
      MemberActions.openIdCard(context, member);

  void _showCallDialog(BuildContext context, GymMember member) =>
      MemberActions.makePhoneCall(context, member);

  void _showWhatsappDialog(BuildContext context, GymMember member) =>
      MemberActions.openWhatsApp(context, member);

  void _quickMarkAttendance(BuildContext context, GymMember member) =>
      MemberActions.markAttendance(context, member);

  void _showRenewPlanDialog(BuildContext context, GymMember member) =>
      MemberActions.renewPlan(context, member);

  void _toggleBlockMember(BuildContext context, GymMember member) =>
      MemberActions.blockMember(context, member);

  void _confirmDeleteMember(BuildContext context, GymMember member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Are you sure you want to delete ${member.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              GymService().deleteMember(member.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Member ${member.fullName} deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryTeal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 26,
                  child: Icon(Icons.fitness_center, color: AppColors.primaryTeal, size: 28),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Gym Manager Pro',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Branch: Main Fitness Center',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.group, color: AppColors.primaryTeal),
            title: const Text('Members Directory'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on, color: AppColors.primaryTeal),
            title: const Text('Change Currency'),
            onTap: () {
              Navigator.pop(context);
              _showCurrencyPicker(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center, color: AppColors.primaryTeal),
            title: const Text('Workout & Exercises'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.primaryTeal),
            title: const Text('Settings'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About Gym Manager'),
            onTap: () {
              Navigator.pop(context);
              _showHelpDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notifications & Alerts (3)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      GymService().setNotificationCount(0);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Mark all read'),
                  ),
                ],
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.notification_important, color: Colors.amber),
                title: Text('Membership Expiry Alerts'),
                subtitle: Text('3 members have memberships expiring this week.'),
              ),
              const ListTile(
                leading: Icon(Icons.account_balance_wallet, color: Colors.green),
                title: Text('Daily Revenue Summary'),
                subtitle: Text('Today\'s fee collections ready for review.'),
              ),
              const ListTile(
                leading: Icon(Icons.fitness_center, color: AppColors.primaryTeal),
                title: Text('Morning Batch Full'),
                subtitle: Text('Morning 7:00 AM slot has reached 90% capacity.'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deleted Members Bin'),
        content: const Text('There are currently no deleted members in the recycle bin.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gym Manager Help'),
        content: const Text(
          'Welcome to Gym Manager!\n\n'
          '• Click "Add Member" to register a new client.\n'
          '• Toggle "M ID" to search by Member ID instead of phone.\n'
          '• Use filter chips to filter by Status, Attention Priority, Plan, or Batch.\n'
          '• Click "Choose Currency" to configure your local business currency.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
