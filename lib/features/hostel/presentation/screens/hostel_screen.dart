import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/repositories/fake_data_repository.dart';
import '../../../../shared/bloc/student_bloc.dart';
import '../../data/repositories/fake_hostel_repository.dart';
import '../bloc/hostel_bloc.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/modern_snackbar.dart';
import '../../../../shared/widgets/sams_pressable.dart';
import '../../../../shared/widgets/sams_state_views.dart';

class HostelScreen extends StatelessWidget {
  const HostelScreen({super.key});

  Future<void> _refreshHostel(BuildContext context) async {
    final bloc = context.read<HostelBloc>();
    bloc.add(const HostelRequested());
    await bloc.stream.firstWhere(
      (state) => state.status != HostelStatus.loading,
    );
    await Future<void>.delayed(const Duration(milliseconds: 180));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HostelBloc(repository: FakeHostelRepository())
            ..add(const HostelRequested()),
      child: BlocBuilder<HostelBloc, HostelState>(
        buildWhen: (previous, current) {
          return previous.status != current.status ||
              previous.menuItems != current.menuItems ||
              previous.errorMessage != current.errorMessage;
        },
        builder: (context, state) {
          if (state.status == HostelStatus.initial ||
              state.status == HostelStatus.loading) {
            return const _HostelLoadingSkeleton();
          }

          if (state.status == HostelStatus.failure) {
            return Scaffold(
              backgroundColor: SamsUiTokens.scaffoldBackground,
              appBar: const SamsAppBar(title: 'SAMS Hostel'),
              body: SamsErrorState(
                title: 'Couldn\'t load hostel services',
                message:
                    state.errorMessage ??
                    'Failed to load hostel services. Please try again.',
                retryLabel: 'Retry',
                onRetry: () =>
                    context.read<HostelBloc>().add(const HostelRequested()),
              ),
            );
          }

          return Scaffold(
            backgroundColor: SamsUiTokens.scaffoldBackground,
            appBar: const SamsAppBar(title: 'SAMS Hostel'),
            body: RefreshIndicator(
              onRefresh: () => _refreshHostel(context),
              color: SamsUiTokens.primary,
              child: SafeArea(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    BlocBuilder<StudentBloc, StudentState>(
                      buildWhen: (previous, current) {
                        return previous.studentName != current.studentName ||
                            previous.studentId != current.studentId ||
                            previous.status != current.status;
                      },
                      builder: (context, studentState) {
                        final name =
                            studentState.studentName ??
                            FakeDataRepository.studentName;
                        final id =
                            studentState.studentId ??
                            FakeDataRepository.studentId;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, $name',
                              style: const TextStyle(
                                color: Color(0xFF1F2937),
                                fontSize: 29,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: $id',
                              style: const TextStyle(
                                color: SamsUiTokens.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Hostel services & requests',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...state.menuItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _HostelMenuCard(
                          key: ValueKey(item.title),
                          title: item.title,
                          subtitle: item.subtitle,
                          icon: _hostelIconFor(item.title),
                          onTap: () {
                            ModernSnackbars.show(
                              context,
                              message: '${item.title} (coming soon)',
                              type: ModernSnackbarType.info,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

IconData _hostelIconFor(String title) {
  final lower = title.toLowerCase();

  if (lower.contains('gate')) {
    return Icons.logout_rounded;
  }

  if (lower.contains('payment') || lower.contains('receipt')) {
    return Icons.receipt_long_rounded;
  }

  if (lower.contains('disciplinary')) {
    return Icons.gavel_rounded;
  }

  if (lower.contains('allotment') || lower.contains('room')) {
    return Icons.meeting_room_rounded;
  }

  return Icons.apartment_rounded;
}

class _HostelLoadingSkeleton extends StatelessWidget {
  const _HostelLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SamsUiTokens.scaffoldBackground,
      appBar: const SamsAppBar(title: 'SAMS Hostel'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: const [
          SamsLoadingView(
            title: 'Loading hostel services',
            message:
                'Preparing your gate pass, receipts and allotment options...',
          ),
          SizedBox(height: 10),
          SamsSkeletonBox(height: 82, radius: 16),
          SizedBox(height: 10),
          SamsSkeletonBox(height: 82, radius: 16),
          SizedBox(height: 10),
          SamsSkeletonBox(height: 82, radius: 16),
        ],
      ),
    );
  }
}

class _HostelMenuCard extends StatelessWidget {
  const _HostelMenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
      child: SamsPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
            boxShadow: SamsUiTokens.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13.2,
                          color: SamsUiTokens.primary,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  icon,
                  color: SamsUiTokens.primary.withValues(alpha: 0.6),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
