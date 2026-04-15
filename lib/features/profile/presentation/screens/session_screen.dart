import 'package:flutter/material.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
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
    const currentSemesterSubjects = [
      'Accounting Principles',
      'Business Administration',
      'Marketing Management',
      'Financial Management',
      'Human Resources Management',
      'Management Information Systems',
      'Economics for Managers',
    ];

    const pastSemesters = [
      (
        title: 'Bachelor of Management Sciences – Semester 4',
        year: '2024-25',
        dates: '10 Feb 2025 – 12 Jun 2025',
        status: 'Completed',
      ),
      (
        title: 'Bachelor of Management Sciences – Semester 3',
        year: '2024-25',
        dates: '28 Sep 2024 – 30 Jan 2025',
        status: 'Completed',
      ),
      (
        title: 'Bachelor of Management Sciences – Semester 2',
        year: '2023-24',
        dates: '12 Feb 2024 – 13 Jun 2024',
        status: 'Completed',
      ),
      (
        title: 'Bachelor of Management Sciences – Semester 1',
        year: '2023-24',
        dates: '30 Sep 2023 – 01 Feb 2024',
        status: 'Completed',
      ),
    ];

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: SizedBox(
            width: 86,
            height: 86,
            child: ShimmerWidget.circle(
              size: 86,
              child: Icon(
                Icons.calendar_month_rounded,
                color: SamsUiTokens.primary,
                size: 34,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SamsAppBar(title: 'Session'),
      body: SafeArea(
        child: ListView(
          padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 20),
          children: [
            const SamsLocaleText(
              'Academic Overview',
              style: TextStyle(
                color: SamsUiTokens.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const SamsLocaleText(
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
                      const SamsLocaleText(
                        'Current Session',
                        style: TextStyle(
                          color: SamsUiTokens.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: SamsUiTokens.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const SamsLocaleText(
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
                  const SamsLocaleText(
                    'Bachelor of Management Sciences – Semester 5',
                    style: TextStyle(
                      color: SamsUiTokens.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const SamsLocaleText(
                    'Academic Year 2025-26 • 27 Sep 2025 – 29 Jan 2026',
                    style: TextStyle(
                      color: SamsUiTokens.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFE6ECF4)),
                  const SizedBox(height: 10),
                  const SamsLocaleText(
                    'Programme: Bachelor of Management Sciences – Semester 5',
                    style: TextStyle(
                      color: SamsUiTokens.textSecondary,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const SamsLocaleText(
                    'Department: Business Administration • Campus: SAMS Cairo (Maadi)',
                    style: TextStyle(
                      color: SamsUiTokens.textSecondary,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFE6ECF4)),
                  const SizedBox(height: 10),
                  const SamsLocaleText(
                    'Semester Subjects',
                    style: TextStyle(
                      color: SamsUiTokens.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currentSemesterSubjects
                        .map(
                          (subject) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: SamsUiTokens.primary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: SamsUiTokens.primary.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ),
                            child: SamsLocaleText(
                              subject,
                              style: const TextStyle(
                                color: SamsUiTokens.primary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SamsLocaleText(
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: SamsUiTokens.primary.withValues(
                                  alpha: 0.1,
                                ),
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
                                  SamsLocaleText(
                                    semester.title,
                                    style: const TextStyle(
                                      color: SamsUiTokens.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  SamsLocaleText(
                                    semester.year,
                                    style: const TextStyle(
                                      color: SamsUiTokens.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  SamsLocaleText(
                                    semester.dates,
                                    style: const TextStyle(
                                      color: SamsUiTokens.textSecondary,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: SamsUiTokens.success.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: SamsLocaleText(
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
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE7EDF5),
                          ),
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
