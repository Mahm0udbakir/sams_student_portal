import 'package:flutter/material.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';

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
        body: Center(child: CircularProgressIndicator()),
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Session',
                    style: TextStyle(
                      color: SamsUiTokens.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'B.Des Semester 5',
                    style: TextStyle(
                      color: SamsUiTokens.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Academic Year 2025-26',
                    style: TextStyle(
                      color: SamsUiTokens.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Programme: Bachelor of Design • Department of Communication Design',
                    style: TextStyle(
                      color: SamsUiTokens.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Advisor: Dr. Meera Khanna • Current Credit Load: 21',
                    style: TextStyle(
                      color: SamsUiTokens.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
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
            ...pastSemesters.map(
              (semester) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDDE4ED)),
                    boxShadow: SamsUiTokens.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: SamsUiTokens.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          color: SamsUiTokens.primary,
                          size: 18,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
