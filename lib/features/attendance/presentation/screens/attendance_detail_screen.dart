import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/fake_attendance_repository.dart';
import '../bloc/attendance_bloc.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_state_views.dart';

class AttendanceDetailScreen extends StatelessWidget {
  const AttendanceDetailScreen({super.key});

  Future<void> _refreshAttendance(BuildContext context) async {
    final bloc = context.read<AttendanceBloc>();
    bloc.add(const AttendanceRequested());
    await bloc.stream.firstWhere((state) => state.status != AttendanceStatus.loading);
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
                              const SizedBox(height: 4),
                              Text(
                                'Overall Attendance: ${state.overallPercent!}%',
                                style: const TextStyle(
                                  color: SamsUiTokens.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
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
                  ...state.classes.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final colors = _attendanceCardColors(item.band);
                      final isActionClass = index == 0;
                      final isMarking =
                          state.actionStatus == AttendanceActionStatus.processing &&
                          state.actionSubject == item.subject;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: colors,
                            ),
                            borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
                            boxShadow: SamsUiTokens.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                              if (isActionClass) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 30,
                                  child: OutlinedButton(
                                    onPressed: isMarking
                                        ? null
                                        : () => context.read<AttendanceBloc>().add(
                                              AttendanceMarkRequested(subject: item.subject),
                                            ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                    child: isMarking
                                        ? const SizedBox(
                                            height: 14,
                                            width: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text('Mark Attendance'),
                                  ),
                                ),
                              ],
                            ],
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

List<Color> _attendanceCardColors(AttendanceBand band) {
  if (band == AttendanceBand.green) {
    return const [Color(0xFF0E8F54), Color(0xFF0A7645)];
  }

  if (band == AttendanceBand.yellow) {
    return const [Color(0xFFB7791F), Color(0xFF996513)];
  }

  return const [Color(0xFFC0352B), Color(0xFFA72C24)];
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
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: const [
          SamsLoadingView(
            title: 'Loading attendance details',
            message: 'Preparing class-wise attendance for you...',
          ),
          SizedBox(height: 8),
          SamsSkeletonBox(height: 84, radius: 18),
          SizedBox(height: 14),
          SamsSkeletonBox(height: 18, width: 160, radius: 6),
          SizedBox(height: 10),
          SamsSkeletonBox(height: 56, radius: 18),
          SizedBox(height: 10),
          SamsSkeletonBox(height: 56, radius: 18),
          SizedBox(height: 10),
          SamsSkeletonBox(height: 56, radius: 18),
        ],
      ),
    );
  }
}
