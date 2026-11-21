import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/gym_models.dart';
import '../services/gym_service.dart';

enum PassStyle { modern, classic, bold }

class GymPassSheet extends StatefulWidget {
  final GymMember member;

  const GymPassSheet({super.key, required this.member});

  static void show(BuildContext context, GymMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GymPassSheet(member: member),
    );
  }

  @override
  State<GymPassSheet> createState() => _GymPassSheetState();
}

class _GymPassSheetState extends State<GymPassSheet> {
  PassStyle _currentStyle = PassStyle.modern;

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final settings = GymService().settings;
    final gymName = settings.gymName.isNotEmpty && settings.gymName != 'Gym Manager'
        ? settings.gymName
        : 'Raja Bhaiaya';
    final gymContact = 'Ravi (+919999746490)';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),

          // Header Row: "Gym Pass" and Close Icon
          Stack(
            alignment: Alignment.center,
            children: [
              const Center(
                child: Text(
                  'Gym Pass',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Color(0xFF4B5563)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Style Selector Tabs: Modern | Classic | Bold
          Container(
            height: 42,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF2F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildTabItem('Modern', PassStyle.modern),
                _buildTabItem('Classic', PassStyle.classic),
                _buildTabItem('Bold', PassStyle.bold),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pass Card Preview
          _buildPassCard(gymName, gymContact),
          const SizedBox(height: 22),

          // Share Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00796B),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gym Pass for ${widget.member.fullName} shared successfully!'),
                ),
              );
            },
            icon: const Icon(Icons.reply, size: 18),
            label: const Text(
              'Share',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),

          // Share Old Pass Link
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fetching previous membership passes...')),
              );
            },
            child: const Text(
              'Share Old Pass',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, PassStyle style) {
    final isSelected = _currentStyle == style;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentStyle = style),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF111827) : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPassCard(String gymName, String gymContact) {
    switch (_currentStyle) {
      case PassStyle.modern:
        return _buildModernCard(gymName, gymContact);
      case PassStyle.classic:
        return _buildClassicCard(gymName, gymContact);
      case PassStyle.bold:
        return _buildBoldCard(gymName, gymContact);
    }
  }

  // ==========================================
  // Modern Pass Style (Screenshot 1)
  // ==========================================
  Widget _buildModernCard(String gymName, String gymContact) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teal Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF00796B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gymName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      gymContact,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.groups, color: Color(0xFF00796B), size: 22),
                ),
              ],
            ),
          ),

          // White Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAvatar(48),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.member.fullName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${widget.member.memberId}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Plan Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PLAN',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.5,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.member.planName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Start / Expiry Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'START',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.5,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(widget.member.joinedDate),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'EXPIRY',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.5,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(widget.member.expiryDate),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Classic Pass Style (Screenshot 2)
  // ==========================================
  Widget _buildClassicCard(String gymName, String gymContact) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFF00796B), width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gym Info
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.groups, size: 20, color: Color(0xFF374151)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gymName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    '+919999746490',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.8),
          const SizedBox(height: 12),

          // Member Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.member.fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00796B),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Grid
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Member ID', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                              const SizedBox(height: 1),
                              Text(widget.member.memberId, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Plan', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                              const SizedBox(height: 1),
                              Text(widget.member.planName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Valid From', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                              const SizedBox(height: 1),
                              Text(_formatDate(widget.member.joinedDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Valid Till', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                              const SizedBox(height: 1),
                              Text(_formatDate(widget.member.expiryDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
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
  // Bold Pass Style (Screenshot 3)
  // ==========================================
  Widget _buildBoldCard(String gymName, String gymContact) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // White Top Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gymName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+919999746490 (Ravi)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.groups, size: 20, color: Color(0xFF374151)),
                ),
              ],
            ),
          ),

          // Teal Bottom Section with Wave
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF00796B),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                _buildAvatar(52, hasWhiteBorder: true),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: ${widget.member.fullName}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Membership Id: ${widget.member.memberId}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Plan Name: ${widget.member.planName}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Start Date: ${_formatDate(widget.member.joinedDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'End Date: ${_formatDate(widget.member.expiryDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(double size, {bool hasWhiteBorder = false}) {
    if (widget.member.photoBase64 != null && widget.member.photoBase64!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: hasWhiteBorder ? Border.all(color: Colors.white, width: 2) : Border.all(color: Colors.grey.shade300),
        ),
        child: ClipOval(
          child: Image.memory(
            base64Decode(widget.member.photoBase64!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
        border: hasWhiteBorder ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Icon(
        Icons.person,
        size: size * 0.65,
        color: Colors.white,
      ),
    );
  }
}
