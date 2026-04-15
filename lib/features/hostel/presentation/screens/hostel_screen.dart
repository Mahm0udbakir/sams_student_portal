import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
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
          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;

          if (state.status == HostelStatus.initial ||
              state.status == HostelStatus.loading) {
            return const _HostelLoadingSkeleton();
          }

          if (state.status == HostelStatus.failure) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: const SamsAppBar(title: 'SAMS Hostel'),
            body: RefreshIndicator(
              onRefresh: () => _refreshHostel(context),
              color: SamsUiTokens.primary,
              child: SafeArea(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
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

                        return _HostelHeroHeader(name: name, id: id);
                      },
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.72,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 14,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.apartment_rounded,
                            size: 19,
                            color: colorScheme.primary,
                          ),
                          SizedBox(width: 9),
                          Expanded(
                            child: SamsLocaleText(
                              'Hostel services & requests',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...state.menuItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HostelMenuCard(
                          key: ValueKey(item.title),
                          title: item.title,
                          subtitle: item.subtitle,
                          icon: _hostelIconFor(item.title),
                          onTap: () {
                            final routeName = _hostelRouteFor(item.title);
                            if (routeName == null) {
                              ModernSnackbars.show(
                                context,
                                message: '${item.title} is not available yet.',
                                type: ModernSnackbarType.info,
                              );
                              return;
                            }
                            context.pushNamed(routeName);
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

String? _hostelRouteFor(String title) {
  final normalized = title.toLowerCase();

  if (normalized.contains('leave')) {
    return AppRouteNames.hostelLeavePermission;
  }

  if (normalized.contains('mess') || normalized.contains('feedback')) {
    return AppRouteNames.hostelMessFeedback;
  }

  if (normalized.contains('fee') || normalized.contains('receipt')) {
    return AppRouteNames.hostelFeeReceipt;
  }

  if (normalized.contains('maintenance') || normalized.contains('request')) {
    return AppRouteNames.hostelMaintenanceRequest;
  }

  return null;
}

IconData _hostelIconFor(String title) {
  final lower = title.toLowerCase();

  if (lower.contains('leave')) {
    return Icons.directions_walk_rounded;
  }

  if (lower.contains('mess') || lower.contains('feedback')) {
    return Icons.restaurant_menu_rounded;
  }

  if (lower.contains('payment') || lower.contains('receipt')) {
    return Icons.receipt_long_rounded;
  }

  if (lower.contains('maintenance') ||
      lower.contains('repair') ||
      lower.contains('issue')) {
    return Icons.handyman_rounded;
  }

  return Icons.apartment_rounded;
}

class _HostelHeroHeader extends StatelessWidget {
  const _HostelHeroHeader({required this.name, required this.id});

  final String name;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF063454), Color(0xFF0A4B75)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33063454),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -18,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.bed_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const SamsLocaleText(
                      'SAMS Hostel',
                      style: TextStyle(
                        color: Color(0xFFD7E9F9),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SamsLocaleText(
                  'Hi, $name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.26),
                    ),
                  ),
                  child: SamsLocaleText(
                    'ID: $id',
                    style: const TextStyle(
                      color: Color(0xFFEAF4FF),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
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

class _HostelLoadingSkeleton extends StatelessWidget {
  const _HostelLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SamsAppBar(title: 'SAMS Hostel'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: const [
          SamsSkeletonBox(height: 164, radius: 22),
          SizedBox(height: 14),
          SamsLoadingView(
            title: 'Loading hostel services',
            message:
                'Preparing your gate pass, receipts and allotment options...',
          ),
          SizedBox(height: 12),
          SamsSkeletonBox(height: 98, radius: 18),
          SizedBox(height: 12),
          SamsSkeletonBox(height: 98, radius: 18),
          SizedBox(height: 12),
          SamsSkeletonBox(height: 98, radius: 18),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    const cardRadius = 18.0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(cardRadius),
      child: SamsPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardRadius),
        baseShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        hoverShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: Offset(0, 9),
          ),
        ],
        pressedShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.72),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        SamsUiTokens.primary.withValues(alpha: 0.96),
                        const Color(0xFF0A4C78),
                      ],
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SamsLocaleText(
                        title,
                        style: TextStyle(
                          fontSize: 16.2,
                          fontWeight: FontWeight.w700,
                          color: textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SamsLocaleText(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.8,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.96,
                          ),
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
