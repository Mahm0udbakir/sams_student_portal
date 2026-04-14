import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../shared/bloc/student_bloc.dart';
import '../../data/repositories/fake_home_repository.dart';
import '../bloc/home_bloc.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/sams_pressable.dart';
import '../../../../shared/widgets/shimmer_widget.dart';
import '../../../../shared/widgets/sams_state_views.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _refreshHome(BuildContext context) async {
    final bloc = context.read<HomeBloc>();
    bloc.add(const HomeRequested());
    try {
      await bloc.stream
          .firstWhere((state) => state.status != HomeStatus.loading)
          .timeout(const Duration(seconds: 6));
    } catch (_) {}
    await Future<void>.delayed(const Duration(milliseconds: 180));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HomeBloc(repository: FakeHomeRepository())
            ..add(const HomeRequested()),
      child: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) {
          return previous.status != current.status ||
              previous.studentName != current.studentName ||
              previous.studentId != current.studentId ||
              previous.overallAttendance != current.overallAttendance ||
              previous.attendanceSubtitle != current.attendanceSubtitle ||
              previous.attendedClassesLabel != current.attendedClassesLabel ||
              previous.busRouteLabel != current.busRouteLabel ||
              previous.busStatusLabel != current.busStatusLabel ||
              previous.announcements != current.announcements ||
              previous.errorMessage != current.errorMessage;
        },
        builder: (context, state) {
          if (state.status == HomeStatus.loading ||
              state.status == HomeStatus.initial) {
            return const _HomeLoadingSkeleton();
          }

          if (state.status == HomeStatus.failure || !state.hasCoreData) {
            return Scaffold(
              backgroundColor: SamsUiTokens.scaffoldBackground,
              body: SamsErrorState(
                title: 'Couldn\'t load home dashboard',
                message:
                    state.errorMessage ??
                    'Failed to load home dashboard. Please try again.',
                retryLabel: 'Retry',
                onRetry: () =>
                    context.read<HomeBloc>().add(const HomeRequested()),
              ),
            );
          }

          final screenWidth = MediaQuery.sizeOf(context).width;
          final horizontalPadding = screenWidth < 360
              ? 12.0
              : SamsUiTokens.pageHPadding;
          final attendancePercent = state.overallAttendance!;
          final attendanceValue = attendancePercent / 100;
          final announcements = state.announcements;

          return Scaffold(
            backgroundColor: SamsUiTokens.scaffoldBackground,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(74),
              child: AppBar(
                title: const SizedBox.shrink(),
                toolbarHeight: 74,
                centerTitle: false,
                automaticallyImplyLeading: false,
                flexibleSpace: SafeArea(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [SamsUiTokens.primary, Color(0xFF04263E)],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: SamsUiTokens.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: BlocBuilder<StudentBloc, StudentState>(
                              buildWhen: (previous, current) {
                                return previous.studentName !=
                                        current.studentName ||
                                    previous.studentId != current.studentId ||
                                    previous.status != current.status;
                              },
                              builder: (context, studentState) {
                                final name =
                                    studentState.studentName ??
                                    state.studentName!;
                                final id =
                                    studentState.studentId ?? state.studentId!;

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'ID: $id',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () => _refreshHome(context),
              color: SamsUiTokens.primary,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Daily Essentials',
                        style: TextStyle(
                          color: SamsUiTokens.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        backgroundColor: SamsUiTokens.primary,
                        title: 'Attendance',
                        subtitle: state.attendanceSubtitle!,
                        trailing: _AttendanceProgress(value: attendanceValue),
                        leadingIcon: Icons.fact_check_rounded,
                        child: _AttendanceMetaSection(
                          label: state.attendedClassesLabel!,
                          onMarkToday: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Today\'s attendance marked successfully.',
                                ),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          context.pushNamed(AppRouteNames.attendanceDetail);
                        },
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        backgroundColor: const Color(0xFF0A4A77),
                        title: 'Track Your Bus',
                        subtitle: state.busRouteLabel!,
                        trailing: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                        leadingIcon: Icons.directions_bus_filled_rounded,
                        child: Text(
                          state.busStatusLabel!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Bus details are available in Menu > SAMS Bus.',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Announcements',
                        style: TextStyle(
                          color: SamsUiTokens.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const _DateSeparator(label: 'Aug 30, Saturday'),
                      const SizedBox(height: 10),
                      if (announcements.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: EmptyStateWidget(
                            icon: Icons.notifications_off_rounded,
                            title: 'No announcements yet',
                            subtitle:
                                'You are all caught up. New updates from SAMS will appear here.',
                            actionLabel: 'Refresh Updates',
                            onAction: () => context.read<HomeBloc>().add(
                              const HomeRequested(),
                            ),
                          ),
                        )
                      else
                        ...announcements.asMap().entries.map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(
                              bottom: entry.key == announcements.length - 1
                                  ? 0
                                  : 10,
                            ),
                            child: _AnnouncementCard(
                              title: entry.value.title,
                              subtitle: entry.value.subtitle,
                              icon: _iconForBadge(entry.value.badge),
                              badge: entry.value.badge,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Opened: ${entry.value.title}',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
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

class _HomeLoadingSkeleton extends StatelessWidget {
  const _HomeLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SamsUiTokens.scaffoldBackground,
      body: SafeArea(
        child: ListView(
          padding: SamsUiTokens.pageInsets(context, top: 16, bottom: 24),
          children: [
            const SamsLoadingView(
              title: 'Loading your dashboard',
              message: 'Fetching attendance, bus status and announcements...',
            ),
            const SizedBox(height: 8),
            const ShimmerWidget(
              height: 134,
              borderRadius: BorderRadius.all(Radius.circular(22)),
            ),
            const SizedBox(height: 12),
            const ShimmerWidget(
              height: 134,
              borderRadius: BorderRadius.all(Radius.circular(22)),
            ),
            const SizedBox(height: 20),
            const ShimmerWidget.line(width: 150, height: 16),
            const SizedBox(height: 10),
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index == 2 ? 0 : 8),
                child: const ShimmerWidget(
                  height: 84,
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _iconForBadge(String badge) {
  switch (badge) {
    case 'Important':
      return Icons.campaign_rounded;
    case 'Financial Aid':
      return Icons.school_rounded;
    case 'Academics':
      return Icons.event_note_rounded;
    case 'Hostel':
      return Icons.night_shelter_rounded;
    default:
      return Icons.notifications_active_rounded;
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.leadingIcon,
    required this.onTap,
    this.child,
  });

  final Color backgroundColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final IconData leadingIcon;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SamsPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SamsUiTokens.radiusXl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor, backgroundColor.withValues(alpha: 0.82)],
          ),
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusXl),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.24),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(SamsUiTokens.radiusMd),
                  ),
                  child: Icon(leadingIcon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 13.2,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                trailing,
              ],
            ),
            if (child != null) ...[const SizedBox(height: 12), child!],
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badge,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SamsPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
          boxShadow: SamsUiTokens.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: SamsUiTokens.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.article_outlined,
                color: SamsUiTokens.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.2,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: SamsUiTokens.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: SamsUiTokens.primary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: SamsUiTokens.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _AttendanceProgress extends StatelessWidget {
  const _AttendanceProgress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
            child: Text(
              '${(value * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceMeta extends StatelessWidget {
  const _AttendanceMeta({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.92),
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _AttendanceMetaSection extends StatelessWidget {
  const _AttendanceMetaSection({
    required this.label,
    required this.onMarkToday,
  });

  final String label;
  final VoidCallback onMarkToday;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _AttendanceMeta(label: label)),
        const SizedBox(width: 12),
        SizedBox(
          height: 34,
          child: OutlinedButton.icon(
            onPressed: onMarkToday,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.76)),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11.8,
              ),
            ),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 14),
            label: const Text('Mark Today\'s Attendance'),
          ),
        ),
      ],
    );
  }
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFD8DEE7), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFD8DEE7), thickness: 1)),
      ],
    );
  }
}
