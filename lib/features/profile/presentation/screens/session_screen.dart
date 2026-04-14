import 'package:flutter/material.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/shimmer_widget.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    const pastSemesters = [
      (title: 'B.Des Semester 4', year: '2024-25', status: 'Completed'),
      (title: 'B.Des Semester 3', year: '2024-25', status: 'Completed'),
      (title: 'B.Des Semester 2', year: '2023-24', status: 'Completed'),
      (title: 'B.Des Semester 1', year: '2023-24', status: 'Completed'),
    ];

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: SamsUiTokens.scaffoldBackground,
        body: Center(
          child: SizedBox(
            width: 86,
            height: 86,
            child: ShimmerWidget.circle(
              size: 86,
              child: Icon(Icons.calendar_month_rounded, color: SamsUiTokens.primary, size: 34),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: SamsUiTokens.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Session'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 20),
          children: [
            const Text(
              'Academic Overview',
              style: TextStyle(
                color: SamsUiTokens.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Track your active semester and previous academic progress.',
              style: TextStyle(
                color: SamsUiTokens.textSecondary,
                fontSize: 12.8,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
                boxShadow: SamsUiTokens.cardShadow,
                border: Border.all(color: SamsUiTokens.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Current Session',
                        style: TextStyle(
                          color: SamsUiTokens.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: SamsUiTokens.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            color: SamsUiTokens.primary,
                            fontSize: 11.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'B.Des Semester 5',
                    style: TextStyle(
                      color: SamsUiTokens.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Academic Year 2025-26',
                    style: TextStyle(
                      color: SamsUiTokens.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFE6ECF4)),
                  const SizedBox(height: 10),
                  const Text(
                    'Programme: Bachelor of Design • Department of Communication Design',
                    style: TextStyle(
                      color: SamsUiTokens.textSecondary,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Advisor: Dr. Meera Khanna • Current Credit Load: 21',
                    style: TextStyle(
                      color: SamsUiTokens.textSecondary,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Past Semesters',
              style: TextStyle(
                color: SamsUiTokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDE4ED)),
                boxShadow: SamsUiTokens.cardShadow,
              ),
              child: Column(
                children: pastSemesters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final semester = entry.value;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: SamsUiTokens.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                color: SamsUiTokens.primary,
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    semester.title,
                                    style: const TextStyle(
                                      color: SamsUiTokens.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    semester.year,
                                    style: const TextStyle(
                                      color: SamsUiTokens.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: SamsUiTokens.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                semester.status,
                                style: const TextStyle(
                                  color: SamsUiTokens.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index != pastSemesters.length - 1)
                        const Padding(
                          padding: EdgeInsets.only(left: 64),
                          child: Divider(height: 1, thickness: 1, color: Color(0xFFE7EDF5)),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
