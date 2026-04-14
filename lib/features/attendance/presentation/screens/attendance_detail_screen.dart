import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/fake_attendance_repository.dart';
import '../bloc/attendance_bloc.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_pressable.dart';
import '../../../../shared/widgets/shimmer_widget.dart';
import '../../../../shared/widgets/sams_state_views.dart';

class AttendanceDetailScreen extends StatelessWidget {
  const AttendanceDetailScreen({super.key});

  Future<void> _refreshAttendance(BuildContext context) async {
    final bloc = context.read<AttendanceBloc>();
    bloc.add(const AttendanceRequested());
    try {
      await bloc.stream
          .firstWhere((state) => state.status != AttendanceStatus.loading)
          .timeout(const Duration(seconds: 6));
    } catch (_) {}
    await Future<void>.delayed(const Duration(milliseconds: 180));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttendanceBloc(repository: FakeAttendanceRepository())..add(const AttendanceRequested()),
      child: BlocListener<AttendanceBloc, AttendanceState>(
        listenWhen: (previous, current) =>
            previous.feedbackMessage != current.feedbackMessage &&
            current.feedbackMessage != null,
        listener: (context, state) {
          final message = state.feedbackMessage;
          if (message == null || message.isEmpty) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          context.read<AttendanceBloc>().add(const AttendanceFeedbackCleared());
        },
        child: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
          if (state.status == AttendanceStatus.loading || state.status == AttendanceStatus.initial) {
            return const _AttendanceLoadingSkeleton();
          }

          if (state.status == AttendanceStatus.failure || !state.hasData) {
            return Scaffold(
              backgroundColor: SamsUiTokens.scaffoldBackground,
              appBar: AppBar(
                title: const Text('Attendance'),
                centerTitle: true,
              ),
              body: SamsErrorState(
                title: 'Couldn\'t load attendance',
                message:
                    state.errorMessage ?? 'Failed to load attendance. Please try again.',
                retryLabel: 'Retry',
                onRetry: () => context.read<AttendanceBloc>().add(const AttendanceRequested()),
              ),
            );
          }

          return Scaffold(
            backgroundColor: SamsUiTokens.scaffoldBackground,
            appBar: AppBar(
              title: const Text('Attendance'),
              centerTitle: true,
            ),
            body: RefreshIndicator(
              onRefresh: () => _refreshAttendance(context),
              color: SamsUiTokens.primary,
              child: SafeArea(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 20),
                  children: [
                  _OverallAttendanceCard(percentage: state.overallPercent!),
                  const SizedBox(height: 12),
                  const _AttendanceLegend(),
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
                  ...state.classes.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final visual = _visualForPercentage(item.percentage);
                      final isActionClass = index == 0;
                      final isMarking =
                          state.actionStatus == AttendanceActionStatus.processing &&
                          state.actionSubject == item.subject;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SamsPressable(
                          borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                            decoration: BoxDecoration(
                              color: visual.background,
                              borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
                              boxShadow: SamsUiTokens.cardShadow,
                              border: Border.all(
                                color: visual.accent.withValues(alpha: 0.30),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                    child: Text(
                                      item.subject,
                                      style: const TextStyle(
                                        color: SamsUiTokens.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: visual.accent.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: visual.accent.withValues(alpha: 0.32),
                                      ),
                                    ),
                                    child: Text(
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
                              Text(
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
                                  height: 30,
                                  child: SamsTapScale(
                                    enabled: !isMarking,
                                    child: OutlinedButton(
                                      onPressed: isMarking
                                          ? null
                                          : () => context.read<AttendanceBloc>().add(
                                                AttendanceMarkRequested(subject: item.subject),
                                              ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: visual.accent.withValues(alpha: 0.75)),
                                        foregroundColor: visual.accent,
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11.5,
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
                                          : const Text('Mark Attendance'),
                                    ),
                                  ),
                                ),
                              ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ],
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

class _AttendanceVisual {
  const _AttendanceVisual({
    required this.background,
    required this.accent,
  });

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
    final visual = _visualForPercentage(percentage);

    return SamsPressable(
      borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
          boxShadow: SamsUiTokens.cardShadow,
          border: Border.all(color: visual.accent.withValues(alpha: 0.26)),
        ),
        child: Row(
          children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Attendance',
                  style: TextStyle(
                    color: SamsUiTokens.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: visual.accent,
                    fontSize: 38,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _bandLabel(percentage),
                  style: TextStyle(
                    color: visual.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 74,
            height: 74,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(visual.accent),
                  backgroundColor: visual.background,
                ),
                Center(
                  child: Icon(
                    Icons.fact_check_rounded,
                    color: visual.accent,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceLegend extends StatelessWidget {
  const _AttendanceLegend();

  @override
  Widget build(BuildContext context) {
    return SamsPressable(
      borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
          boxShadow: SamsUiTokens.cardShadow,
          border: Border.all(color: SamsUiTokens.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
          Text(
            'Attendance Color Guide',
            style: TextStyle(
              color: SamsUiTokens.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _LegendChip(label: '≥ 80%', color: Color(0xFF0E8F54)),
              _LegendChip(label: '60% – 79%', color: Color(0xFFB7791F)),
              _LegendChip(label: '< 60%', color: Color(0xFFC0352B)),
            ],
          ),
          ],
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.label, required this.color});

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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
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
      backgroundColor: SamsUiTokens.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Attendance'),
        centerTitle: true,
      ),
      body: ListView(
        padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 20),
        children: [
          const SamsLoadingView(
            title: 'Loading your attendance...',
            message: 'Preparing overall and class-wise attendance for you...',
          ),
          const SizedBox(height: 8),
          const ShimmerWidget(height: 84, borderRadius: BorderRadius.all(Radius.circular(18))),
          const SizedBox(height: 14),
          const ShimmerWidget.line(width: 170, height: 16),
          const SizedBox(height: 10),
          ...List.generate(
            4,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index == 3 ? 0 : 10),
              child: const ShimmerWidget(
                height: 56,
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
