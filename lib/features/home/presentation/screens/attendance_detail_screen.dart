import 'package:flutter/material.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_app_bar.dart';

class AttendanceDetailScreen extends StatelessWidget {
  const AttendanceDetailScreen({super.key});

  static const _overallAttendance = 75;

  @override
  Widget build(BuildContext context) {
    const attendanceItems = [
      (subject: 'Accounting Principles', percentage: 92),
      (subject: 'Marketing Management', percentage: 84),
      (subject: 'Financial Management', percentage: 78),
      (subject: 'Business Administration', percentage: 74),
      (subject: 'Human Resources Management', percentage: 65),
      (subject: 'Business Law', percentage: 59),
      (subject: 'Economics for Managers', percentage: 52),
      (subject: 'Business Statistics', percentage: 38),
    ];

    return Scaffold(
      backgroundColor: SamsUiTokens.scaffoldBackground,
      appBar: const SamsAppBar(title: 'Attendance'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
                boxShadow: SamsUiTokens.cardShadow,
                border: Border.all(color: SamsUiTokens.divider),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: SamsUiTokens.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fact_check_rounded,
                      color: SamsUiTokens.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Attendance',
                          style: TextStyle(
                            color: SamsUiTokens.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Overall Attendance: 75%',
                          style: TextStyle(
                            color: SamsUiTokens.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _overallBadgeColor(
                        _overallAttendance,
                      ).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$_overallAttendance%',
                      style: TextStyle(
                        color: _overallBadgeColor(_overallAttendance),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Class-wise Attendance',
              style: TextStyle(
                color: SamsUiTokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            ...attendanceItems.map((item) {
              final colors = _attendanceCardColors(item.percentage);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                    borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
                    boxShadow: SamsUiTokens.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.subject,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.24),
                          ),
                        ),
                        child: Text(
                          '${item.percentage}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

List<Color> _attendanceCardColors(int percentage) {
  if (percentage >= 80) {
    return const [Color(0xFF0E8F54), Color(0xFF0A7645)];
  }

  if (percentage >= 60) {
    return const [Color(0xFFB7791F), Color(0xFF996513)];
  }

  return const [Color(0xFFC0352B), Color(0xFFA72C24)];
}

Color _overallBadgeColor(int percentage) {
  if (percentage >= 80) return SamsUiTokens.success;
  if (percentage >= 60) return SamsUiTokens.warning;
  return SamsUiTokens.danger;
}
