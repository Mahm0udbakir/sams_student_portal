import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/portal_courses.dart';
import '../../../../core/services/camera_permission_service.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/modern_snackbar.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/sams_pressable.dart';
import '../../../../shared/widgets/sams_state_views.dart';
import '../../../../shared/widgets/shimmer_widget.dart';
import '../../data/repositories/firestore_attendance_repository.dart';
import '../../domain/entities/attendance_session_entity.dart';
import '../bloc/attendance_bloc.dart';
import 'attendance_scanner_screen.dart';

class AttendanceDetailScreen extends StatelessWidget {
  const AttendanceDetailScreen({super.key});

  Future<void> _refreshAttendance(BuildContext context) async {
    final bloc = context.read<AttendanceBloc>();
    bloc.add(const AttendanceRequested());
    try {
      await bloc.stream
          .firstWhere((state) => state.status != AttendanceStatus.loading)
          .timeout(const Duration(seconds: 8));
    } catch (_) {}
    await Future<void>.delayed(const Duration(milliseconds: 160));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AttendanceBloc(repository: FirestoreAttendanceRepository())
            ..add(const AttendanceRequested()),
      child: BlocConsumer<AttendanceBloc, AttendanceState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus ||
            previous.feedbackMessage != current.feedbackMessage,
        listener: (context, state) {
          if (state.actionStatus == AttendanceActionStatus.success &&
              (state.feedbackMessage ?? '').isNotEmpty) {
            ModernSnackbars.show(
              context,
              message: state.feedbackMessage!,
              type: ModernSnackbarType.success,
            );
            context.read<AttendanceBloc>().add(const AttendanceFeedbackCleared());
          } else if (state.actionStatus == AttendanceActionStatus.failure &&
              (state.feedbackMessage ?? '').isNotEmpty) {
            ModernSnackbars.show(
              context,
              message: state.feedbackMessage!,
              type: ModernSnackbarType.error,
            );
            context.read<AttendanceBloc>().add(const AttendanceFeedbackCleared());
          }
        },
        builder: (context, state) {
          if (state.status == AttendanceStatus.loading ||
              state.status == AttendanceStatus.initial) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: const SamsAppBar(title: 'Attendance'),
              body: ListView(
                padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 24),
                children: [
                  const SamsLoadingView(
                    title: 'Loading your attendance',
                    message: 'Fetching courses, session counts, and scan history from Firestore…',
                  ),
                  const SizedBox(height: 16),
                  const ShimmerWidget(
                    height: 112,
                    borderRadius: BorderRadius.all(Radius.circular(SamsUiTokens.radiusXl)),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(
                    4,
                    (i) => Padding(
                      padding: EdgeInsets.only(bottom: i == 3 ? 0 : 10),
                      child: const ShimmerWidget(
                        height: 168,
                        borderRadius: BorderRadius.all(Radius.circular(SamsUiTokens.radiusLg)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state.status == AttendanceStatus.failure) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: const SamsAppBar(title: 'Attendance'),
              body: SamsErrorState(
                title: 'Could not load attendance',
                message: state.errorMessage ?? 'Please try again.',
                retryLabel: 'Retry',
                onRetry: () =>
                    context.read<AttendanceBloc>().add(const AttendanceRequested()),
              ),
            );
          }

          final overall = state.overallPercent ?? 0;
          final dateFmt = DateFormat('d MMM yyyy');

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
                      padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 24),
                      children: [
                        if (state.sessions.isNotEmpty) ...[
                          _SectionTitle(
                            title: 'Active sessions',
                            subtitle: 'Open QR sessions from your instructors',
                          ),
                          const SizedBox(height: 10),
                          ...state.sessions.map(
                            (session) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ActiveSessionCard(session: session),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        _OverallAttendanceHero(percentage: overall),
                        const SizedBox(height: 14),
                        const _AttendanceLegend(),
                        const SizedBox(height: 20),
                        _SectionTitle(
                          title: 'Your courses',
                          subtitle:
                              '${PortalCourses.curriculum.length} courses · Live from Firestore',
                        ),
                        const SizedBox(height: 12),
                        ...state.classes.map((item) {
                          final isMarking =
                              state.actionStatus == AttendanceActionStatus.processing &&
                              state.actionSubject == item.subject;
                          return Padding(
                            key: ValueKey(item.subject),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CourseAttendanceCard(
                              item: item,
                              dateFormatter: dateFmt,
                              isMarking: isMarking,
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
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SamsLocaleText(
          title,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        SamsLocaleText(
          subtitle,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _OverallAttendanceHero extends StatelessWidget {
  const _OverallAttendanceHero({required this.percentage});

  final int percentage;

  @override
  Widget build(BuildContext context) {
    final value = (percentage.clamp(0, 100)) / 100.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SamsUiTokens.primary,
            SamsUiTokens.primary.withValues(alpha: 0.88),
            const Color(0xFF063454),
          ],
        ),
        borderRadius: BorderRadius.circular(SamsUiTokens.radiusXl),
        boxShadow: [
          BoxShadow(
            color: SamsUiTokens.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SamsLocaleText(
                  'Overall attendance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                SamsLocaleText(
                  'Average across your ${PortalCourses.curriculum.length} SAMS courses this term.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12.8,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                ),
                CircularProgressIndicator(
                  value: value,
                  backgroundColor: Colors.white.withValues(alpha: 0.26),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 5,
                ),
                Center(
                  child: SamsLocaleText(
                    '$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseAttendanceCard extends StatelessWidget {
  const _CourseAttendanceCard({
    required this.item,
    required this.dateFormatter,
    required this.isMarking,
  });

  final AttendanceClassItem item;
  final DateFormat dateFormatter;
  final bool isMarking;

  static const int _maxVisibleScanChips = 8;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visual = _visualForPercentage(item.percentage);
    final scheduled = item.scheduledSessionCount;
    final attended = item.attendedCount;
    final sessionLine = scheduled > 0
        ? '$attended of $scheduled sessions attended'
        : attended > 0
            ? '$attended session${attended == 1 ? '' : 's'} recorded'
            : 'No sessions recorded yet';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHigh.withValues(alpha: 0.94)
            : cs.surfaceContainerHighest.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
        border: Border.all(
          color: visual.accent.withValues(alpha: isDark ? 0.42 : 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 5,
                  color: visual.accent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SamsLocaleText(
                                item.subject,
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: visual.accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: visual.accent.withValues(alpha: 0.35),
                                ),
                              ),
                              child: SamsLocaleText(
                                '${item.percentage}%',
                                style: TextStyle(
                                  color: visual.accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.event_available_rounded,
                              size: 18,
                              color: visual.accent,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SamsLocaleText(
                                sessionLine,
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(
                          height: 1,
                          color: cs.outlineVariant.withValues(alpha: 0.65),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 16,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            SamsLocaleText(
                              'Scan history',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (item.scanDates.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: SamsLocaleText(
                              'No scan dates yet — tap Scan with camera after your lecture.',
                              style: TextStyle(
                                color: cs.onSurfaceVariant.withValues(alpha: 0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...item.scanDates
                                  .take(_maxVisibleScanChips)
                                  .map(
                                    (d) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: visual.accent.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: visual.accent.withValues(alpha: 0.22),
                                        ),
                                      ),
                                      child: SamsLocaleText(
                                        dateFormatter.format(d.toLocal()),
                                        style: TextStyle(
                                          color: visual.accent,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ),
                                  ),
                              if (item.scanDates.length > _maxVisibleScanChips)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: cs.outlineVariant.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  child: SamsLocaleText(
                                    '+${item.scanDates.length - _maxVisibleScanChips} more',
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: visual.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SamsLocaleText(
                            _bandLabel(item.percentage),
                            style: TextStyle(
                              color: visual.accent,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: SamsTapScale(
                            enabled: !isMarking,
                            child: FilledButton.icon(
                              onPressed: isMarking
                                  ? null
                                  : () => _onScanPressed(context, item.subject),
                              style: FilledButton.styleFrom(
                                backgroundColor: SamsUiTokens.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    SamsUiTokens.radiusMd,
                                  ),
                                ),
                              ),
                              icon: isMarking
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white.withValues(alpha: 0.9),
                                      ),
                                    )
                                  : const Icon(Icons.photo_camera_outlined, size: 20),
                              label: SamsLocaleText(
                                isMarking ? 'Recording…' : 'Scan with camera',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
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
    );
  }

  Future<void> _onScanPressed(BuildContext context, String courseSubject) async {
    final granted = await CameraPermissionService().ensureCameraPermission();
    if (!context.mounted) return;
    if (!granted) {
      ModernSnackbars.show(
        context,
        message: 'Camera permission is required to scan attendance QR codes.',
        type: ModernSnackbarType.info,
      );
      return;
    }
    final scanned = await Navigator.of(context).push<String?>(
      MaterialPageRoute(
        builder: (_) => AttendanceScannerScreen(courseTitle: courseSubject),
      ),
    );
    if (!context.mounted) return;
    if (scanned == null || scanned.trim().isEmpty) return;

    var sessionId = scanned.trim();
    try {
      final decoded = jsonDecode(scanned);
      if (decoded is Map && decoded['sessionId'] is String) {
        sessionId = decoded['sessionId'] as String;
      }
    } catch (_) {}

    context.read<AttendanceBloc>().add(
          AttendanceRecordRequested(
            sessionId: sessionId,
            courseSubject: courseSubject,
          ),
        );
  }
}

class _ActiveSessionCard extends StatelessWidget {
  const _ActiveSessionCard({required this.session});

  final AttendanceSessionEntity session;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.75)),
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
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                SamsLocaleText(
                  '${session.room} · ${session.sessionId}',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
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
                  : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              session.isActive ? 'Open' : 'Closed',
              style: TextStyle(
                color: session.isActive ? const Color(0xFF0E8F54) : cs.onSurfaceVariant,
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
  if (percentage >= 80) return 'On track (≥ 80%)';
  if (percentage >= 60) return 'Needs attention (60–79%)';
  return 'At risk (< 60%)';
}

class _AttendanceLegend extends StatelessWidget {
  const _AttendanceLegend();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _LegendChip(
          label: 'On track (≥80%)',
          color: const Color(0xFF0E8F54),
          surface: cs.surfaceContainerHighest,
        ),
        _LegendChip(
          label: 'Watch (60–79%)',
          color: const Color(0xFFB7791F),
          surface: cs.surfaceContainerHighest,
        ),
        _LegendChip(
          label: 'At risk (<60%)',
          color: const Color(0xFFC0352B),
          surface: cs.surfaceContainerHighest,
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.label,
    required this.color,
    required this.surface,
  });

  final String label;
  final Color color;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
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
