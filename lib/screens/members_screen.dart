import 'package:flutter/material.dart';
import '../services/gym_service.dart';
import '../models/gym_models.dart';
import '../constants/app_colors.dart';
import '../widgets/add_member_dialog.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/currency_picker_dialog.dart';

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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddMemberModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const AddMemberDialog(),
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

          // Status filter
          if (_filterStatus == 'Active' && m.status != MemberStatus.active) return false;
          if (_filterStatus == 'Expired' && !m.isExpired) return false;
          if (_filterStatus == 'Pending Dues' && !m.hasDues) return false;

          // Attention filter
          if (_filterAttention == 'Expiring in 7 Days' && (m.daysRemaining > 7 || m.isExpired)) return false;
          if (_filterAttention == 'Already Expired' && !m.isExpired) return false;
          if (_filterAttention == 'Has Unpaid Dues' && !m.hasDues) return false;

          // Plan filter
          if (_filterPlan != 'All Plans' && !m.planName.toLowerCase().contains(_filterPlan.toLowerCase())) return false;

          // Batch filter
          if (_filterBatch != 'Select Batch' && m.batch != _filterBatch) return false;

          return true;
        }).toList();

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
                                      ? 'Search for "Member ID"'
                                      : 'Search for "Mobile"',
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
                  title: 'Filter by Status',
                  options: ['All', 'Active', 'Expired', 'Pending Dues'],
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
                  title: 'Attention Priority',
                  options: [
                    'Needs Attention First',
                    'Expiring in 7 Days',
                    'Already Expired',
                    'Has Unpaid Dues',
                  ],
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
                  title: 'Filter by Plan',
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
                  title: 'Filter by Batch',
                  options: ['Select Batch', 'Morning', 'Evening', 'General Day', '24/7 Access'],
                  selectedOption: _filterBatch,
                  onSelected: (val) => setState(() => _filterBatch = val),
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

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final m = members[index];
        final isExpired = m.isExpired;
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: isExpired
                  ? Colors.red.shade100
                  : AppColors.primaryTeal.withOpacity(0.12),
              child: Text(
                m.fullName.isNotEmpty ? m.fullName[0].toUpperCase() : 'M',
                style: TextStyle(
                  color: isExpired ? Colors.red : AppColors.primaryTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    m.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isExpired ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isExpired ? Colors.red : Colors.green),
                  ),
                  child: Text(
                    isExpired ? 'Expired' : 'Active',
                    style: TextStyle(
                      color: isExpired ? Colors.red : Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('ID: ${m.memberId} | 📱 ${m.phone}', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 2),
                Text('Plan: ${m.planName} (${m.batch})', style: const TextStyle(fontSize: 12, color: AppColors.textGray)),
                if (m.hasDues)
                  Text('Dues: $currency${m.duesAmount}', style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'delete') {
                  GymService().deleteMember(m.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Member ${m.fullName} removed')),
                  );
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'view', child: Text('View Profile')),
                const PopupMenuItem(value: 'renew', child: Text('Renew Membership')),
                const PopupMenuItem(value: 'delete', child: Text('Delete Member', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        );
      },
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
