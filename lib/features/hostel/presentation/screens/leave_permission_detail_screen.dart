import 'package:flutter/material.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/modern_snackbar.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/sams_pressable.dart';

class LeavePermissionDetailScreen extends StatefulWidget {
  const LeavePermissionDetailScreen({super.key});

  @override
  State<LeavePermissionDetailScreen> createState() =>
      _LeavePermissionDetailScreenState();
}

class _LeavePermissionDetailScreenState
    extends State<LeavePermissionDetailScreen> {
  final TextEditingController _reasonController = TextEditingController(
    text: 'Family visit in Alexandria during the weekend.',
  );
  final TextEditingController _guardianContactController =
      TextEditingController(text: '+20 100 123 4567');

  DateTime _leaveDate = DateTime(2026, 4, 18);
  DateTime _returnDate = DateTime(2026, 4, 20);
  String _passType = 'Weekend';

  @override
  void dispose() {
    _reasonController.dispose();
    _guardianContactController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isLeaveDate}) async {
    final now = DateTime.now();
    final initialDate = isLeaveDate ? _leaveDate : _returnDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
      helpText: isLeaveDate ? 'Select leave date' : 'Select return date',
    );

    if (picked == null) {
      return;
    }

    setState(() {
      if (isLeaveDate) {
        _leaveDate = picked;
        if (_returnDate.isBefore(_leaveDate)) {
          _returnDate = _leaveDate.add(const Duration(days: 1));
        }
      } else {
        _returnDate = picked.isBefore(_leaveDate)
            ? _leaveDate.add(const Duration(days: 1))
            : picked;
      }
    });
  }

  String _formatDate(DateTime date) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  void _submitRequest() {
    if (_reasonController.text.trim().isEmpty ||
        _guardianContactController.text.trim().isEmpty) {
      ModernSnackbars.show(
        context,
        message: 'Please fill reason and guardian contact before submitting.',
        type: ModernSnackbarType.error,
      );
      return;
    }

    ModernSnackbars.show(
      context,
      message: 'Leave permission request submitted to Hostel Warden.',
      type: ModernSnackbarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SamsUiTokens.scaffoldBackground,
      appBar: const SamsAppBar(title: 'Leave Permission'),
      body: SafeArea(
        child: ListView(
          padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF063454), Color(0xFF0B4C76)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2E063454),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Hostel Status',
                    style: TextStyle(
                      color: Color(0xFFD7EBFA),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Room B-214 • Floor 2\nLast pass approved on 10 Apr 2026',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Request details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pass type',
                    style: TextStyle(
                      color: SamsUiTokens.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Weekend', 'Emergency', 'Academic']
                        .map(
                          (type) => ChoiceChip(
                            label: Text(type),
                            selected: _passType == type,
                            onSelected: (_) => setState(() => _passType = type),
                            selectedColor: SamsUiTokens.primary.withValues(
                              alpha: 0.14,
                            ),
                            labelStyle: TextStyle(
                              color: _passType == type
                                  ? SamsUiTokens.primary
                                  : SamsUiTokens.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                            side: BorderSide(
                              color: _passType == type
                                  ? SamsUiTokens.primary.withValues(alpha: 0.32)
                                  : const Color(0xFFDDE5EE),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DateTile(
                          label: 'Leave date',
                          value: _formatDate(_leaveDate),
                          onTap: () => _pickDate(isLeaveDate: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DateTile(
                          label: 'Return date',
                          value: _formatDate(_returnDate),
                          onTap: () => _pickDate(isLeaveDate: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _guardianContactController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Guardian contact',
                      hintText: '+20 1XX XXX XXXX',
                      prefixIcon: Icon(Icons.call_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _reasonController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      hintText: 'Briefly explain your leave request...',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.edit_note_rounded),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _SectionCard(
              title: 'Approval flow',
              child: Column(
                children: [
                  _TimelineRow(
                    title: 'Request created',
                    subtitle: 'Auto-generated on submit',
                    isActive: true,
                  ),
                  _TimelineRow(
                    title: 'Hostel Warden review',
                    subtitle: 'Usually within 2-4 hours',
                  ),
                  _TimelineRow(
                    title: 'Gate office validation',
                    subtitle: 'Final check before departure',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SamsTapScale(
              child: ElevatedButton.icon(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SamsUiTokens.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(SamsUiTokens.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.send_rounded),
                label: const Text('Submit leave request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SamsPressable(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDDE5EE)),
          boxShadow: SamsUiTokens.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: SamsUiTokens.textPrimary,
                fontSize: 15.4,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SamsPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDDE5EF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: SamsUiTokens.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: SamsUiTokens.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 15,
                  color: SamsUiTokens.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.title,
    required this.subtitle,
    this.isActive = false,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final bool isActive;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? SamsUiTokens.primary
                    : const Color(0xFFB9C9D8),
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 34, color: const Color(0xFFD7E3EE)),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: SamsUiTokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: SamsUiTokens.textSecondary,
                    fontSize: 12.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
