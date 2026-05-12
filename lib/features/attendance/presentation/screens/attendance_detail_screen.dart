import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/firestore_attendance_repository.dart';
import '../../domain/entities/attendance_session_entity.dart';
import '../bloc/attendance_bloc.dart';
import 'attendance_scanner_screen.dart';
import '../../../../core/services/camera_permission_service.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
                                      // --- Start new layout ---
                                      Row(
                                        children: [
                                          Container(
                                            width: 5,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: visual.accent,
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: SamsLocaleText(
                                              item.subject,
                                              style: const TextStyle(
                                                color: SamsUiTokens.textPrimary,
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
                                              color: visual.accent.withValues(alpha: 0.14),
                                              borderRadius: BorderRadius.circular(999),
                                              border: Border.all(
                                                color: visual.accent.withValues(alpha: 0.32),
                                              ),
                                            ),
                                            child: SamsLocaleText(
                                              '${item.percentage}%',
                                              style: TextStyle(
                                                color: visual.accent,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.qr_code_2_rounded, size: 16, color: visual.accent),
                                          const SizedBox(width: 6),
                                          SamsLocaleText(
                                            'Attended: ${item.attendedCount}',
                                            style: TextStyle(
                                              color: visual.accent,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (item.scanDates.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        SamsLocaleText(
                                          'Scan History:',
                                          style: TextStyle(
                                            color: SamsUiTokens.textSecondary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        SizedBox(
                                          height: 28,
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: item.scanDates.length,
                                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                                            itemBuilder: (context, idx) {
                                              final date = item.scanDates[idx];
                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: visual.accent.withValues(alpha: 0.10),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: SamsLocaleText(
                                                  '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                                                  style: TextStyle(
                                                    color: visual.accent,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 11.5,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 6),
                                      SamsLocaleText(
                                        _bandLabel(item.percentage),
                                        style: TextStyle(
                                          color: visual.accent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (isActionClass) ...[
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 38,
                                          child: SamsTapScale(
                                            enabled: !isMarking,
                                            child: OutlinedButton(
                                              onPressed: isMarking
                                                  ? null
                                                  : () async {
                                                      final permissionGranted = await CameraPermissionService().ensureCameraPermission();
                                                      if (!permissionGranted) {
                                                        if (context.mounted) {
                                                          ModernSnackbars.show(
                                                            context,
                                                            message: 'Camera permission is required to scan attendance QR codes.',
                                                            type: ModernSnackbarType.info,
                                                          );
                                                        }
                                                        return;
                                                      }
                                                      final scanned = await Navigator.of(context).push<String?>(
                                                        MaterialPageRoute(
                                                          builder: (_) => const AttendanceScannerScreen(),
                                                        ),
                                                      );
                                                      if (scanned != null && scanned.isNotEmpty) {
                                                        String sessionId = scanned;
                                                        try {
                                                          final decoded = jsonDecode(scanned);
                                                          if (decoded is Map && decoded['sessionId'] is String) {
                                                            sessionId = decoded['sessionId'] as String;
                                                          }
                                                        } catch (_) {}
                                                        context.read<AttendanceBloc>().add(
                                                          AttendanceRecordRequested(sessionId: sessionId),
                                                        );
                                                      }
                                                    },
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                  color: visual.accent.withValues(alpha: 0.75),
                                                ),
                                                foregroundColor: visual.accent,
                                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                                textStyle: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              child: isMarking
                                                  ? SizedBox(
                                                      height: 14,
                                                      width: 14,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation<Color>(visual.accent),
                                                      ),
                                                    )
                                                  : const SamsLocaleText('Scan QR Code'),
                                            ),
                                          ),
                                        ),
                                      ],
                                      // --- End new layout ---
                            'Once an admin creates the first attendance session, the live overview and QR actions will appear here.',
                      ),
                    ],
                  ),
                ),
              );
            }

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: const SamsAppBar(title: 'Attendance'),
              body: RefreshIndicator(
                onRefresh: () => _refreshAttendance(context),
                color: SamsUiTokens.primary,
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: SamsUiTokens.contentMaxWidth,
                      ),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: SamsUiTokens.pageInsets(
                          context,
                          top: 14,
                          bottom: 20,
                        ),
                        children: [
                          if (state.sessions.isNotEmpty) ...[
                            const SamsLocaleText(
                              'Active sessions',
                              style: TextStyle(
                                color: SamsUiTokens.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...state.sessions.map(
                              (session) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ActiveSessionCard(session: session),
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          _OverallAttendanceCard(
                            percentage: state.overallPercent!,
                          ),
                          const SizedBox(height: 12),
                          const _AttendanceLegend(),
                          const SizedBox(height: 14),
                          const SamsLocaleText(
                            'Class-wise Attendance',
                            style: TextStyle(
                              color: SamsUiTokens.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...state.classes.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final visual = _visualForPercentage(
                              item.percentage,
                            );
                            final isActionClass = index == 0;
                            final isMarking =
                                state.actionStatus ==
                                    AttendanceActionStatus.processing &&
                                state.actionSubject == item.subject;

                            return Padding(
                              key: ValueKey(item.subject),
                              padding: const EdgeInsets.only(bottom: 10),
                              child: SamsPressable(
                                borderRadius: BorderRadius.circular(
                                  SamsUiTokens.radiusLg,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 13,
                                  ),
                                  decoration: BoxDecoration(
                                    color: visual.background,
                                    borderRadius: BorderRadius.circular(
                                      SamsUiTokens.radiusLg,
                                    ),
                                    boxShadow: SamsUiTokens.cardShadow,
                                    border: Border.all(
                                      color: visual.accent.withValues(
                                        alpha: 0.30,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 5,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: visual.accent,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: SamsLocaleText(
                                              item.subject,
                                              style: const TextStyle(
                                                color: SamsUiTokens.textPrimary,
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
                                              color: visual.accent.withValues(
                                                alpha: 0.14,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              border: Border.all(
                                                color: visual.accent.withValues(
                                                  alpha: 0.32,
                                                ),
                                              ),
                                            ),
                                            child: SamsLocaleText(
                                              '${item.percentage}%',
                                              style: TextStyle(
                                                color: visual.accent,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      SamsLocaleText(
                                        _bandLabel(item.percentage),
                                        style: TextStyle(
                                          color: visual.accent,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (isActionClass) ...[
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 38,
                                          child: SamsTapScale(
                                            enabled: !isMarking,
                                            child: OutlinedButton(
                                                  onPressed: isMarking
                                                      ? null
                                                      : () async {
                                                          final permissionGranted =
                                                              await CameraPermissionService()
                                                                  .ensureCameraPermission();

                                                          if (!permissionGranted) {
                                                            if (context.mounted) {
                                                              ModernSnackbars.show(
                                                                context,
                                                                message:
                                                                    'Camera permission is required to scan attendance QR codes.',
                                                                type:
                                                                    ModernSnackbarType.info,
                                                              );
                                                            }
                                                            return;
                                                          }

                                                          // Open scanner and submit scanned sessionId
                                                          final scanned = await Navigator.of(context).push<String?>(
                                                            MaterialPageRoute(
                                                              builder: (_) => const AttendanceScannerScreen(),
                                                            ),
                                                          );

                                                          if (scanned != null && scanned.isNotEmpty) {
                                                            String sessionId = scanned;
                                                            try {
                                                              final decoded = jsonDecode(scanned);
                                                              if (decoded is Map && decoded['sessionId'] is String) {
                                                                sessionId = decoded['sessionId'] as String;
                                                              }
                                                            } catch (_) {
                                                              // ignore - treat scanned value as raw sessionId
                                                            }

                                                            context.read<AttendanceBloc>().add(
                                                              AttendanceRecordRequested(sessionId: sessionId),
                                                            );
                                                          }
                                                        },
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                  color: visual.accent
                                                      .withValues(alpha: 0.75),
                                                ),
                                                foregroundColor: visual.accent,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                                textStyle: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              child: isMarking
                                                  ? SizedBox(
                                                      height: 14,
                                                      width: 14,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(visual.accent),
                                                      ),
                                                    )
                                                  : const SamsLocaleText(
                                                      'Scan QR Code',
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActiveSessionCard extends StatelessWidget {
  const _ActiveSessionCard({required this.session});

  final AttendanceSessionEntity session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
        border: Border.all(color: SamsUiTokens.divider),
        boxShadow: SamsUiTokens.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: SamsUiTokens.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.qr_code_2_rounded, color: SamsUiTokens.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SamsLocaleText(
                  session.subject,
                  style: const TextStyle(
                    color: SamsUiTokens.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                SamsLocaleText(
                  '${session.room} • ${session.sessionId}',
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: session.isActive
                  ? const Color(0xFFE9F8EF)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              session.isActive ? 'Open' : 'Closed',
              style: TextStyle(
                color: session.isActive ? const Color(0xFF0E8F54) : const Color(0xFF6B7280),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceVisual {
  const _AttendanceVisual({required this.background, required this.accent});

  final Color background;
  final Color accent;
}

_AttendanceVisual _visualForPercentage(int percentage) {
  if (percentage >= 80) {
    return const _AttendanceVisual(
      background: Color(0xFFF0FAF5),
      accent: Color(0xFF0E8F54),
    );
  }

  if (percentage >= 60) {
    return const _AttendanceVisual(
      background: Color(0xFFFFF7EB),
      accent: Color(0xFFB7791F),
    );
  }

  return const _AttendanceVisual(
    background: Color(0xFFFFF1F0),
    accent: Color(0xFFC0352B),
  );
}

String _bandLabel(int percentage) {
  if (percentage >= 80) {
    return 'Safe Zone (≥ 80%)';
  }

  if (percentage >= 60) {
    return 'Watch Zone (60–79%)';
  }

  return 'Critical Zone (< 60%)';
}

class _OverallAttendanceCard extends StatelessWidget {
  const _OverallAttendanceCard({required this.percentage});

  final int percentage;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 420;
    final visual = _visualForPercentage(percentage);

    return SamsPressable(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: buildAttendanceCourseChildren(item, visual, isActionClass, isMarking, context),
                      ),
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.label, required this.color});
import './_attendance_course_helpers.dart';

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          SamsLocaleText(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceLoadingSkeleton extends StatelessWidget {
  const _AttendanceLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SamsAppBar(title: 'Attendance'),
      body: ListView(
        padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 20),
        children: [
          const SamsLoadingView(
            title: 'Loading your attendance...',
            message: 'Preparing overall and class-wise attendance for you...',
          ),
          const SizedBox(height: 8),
                          const SamsLocaleText(
                            'Class-wise Attendance',
                            style: TextStyle(
                              color: SamsUiTokens.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...state.classes.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final visual = _visualForPercentage(item.percentage);
                            final isActionClass = index == 0;
                            final isMarking =
                                state.actionStatus == AttendanceActionStatus.processing &&
                                state.actionSubject == item.subject;
                            return Padding(
                              key: ValueKey(item.subject),
                              padding: const EdgeInsets.only(bottom: 10),
                              child: SamsPressable(
                                borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: buildAttendanceCourseChildren(item, visual, isActionClass, isMarking, context),
                                ),
                              ),
                            );
                          }),
