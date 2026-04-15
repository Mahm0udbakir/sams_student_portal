import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../data/repositories/fake_home_repository.dart';
import '../bloc/home_bloc.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/modern_snackbar.dart';
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
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          final isDesktop = SamsUiTokens.isDesktopWidth(context);
          final horizontalPadding = screenWidth < 360
              ? 12.0
              : SamsUiTokens.pageHPadding;
          final attendancePercent = state.overallAttendance!;
          final attendanceValue = attendancePercent / 100;
          final announcements = state.announcements;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: const SamsAppBar(title: 'Home'),
            body: RefreshIndicator(
              onRefresh: () => _refreshHome(context),
              color: SamsUiTokens.primary,
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: SamsUiTokens.contentMaxWidth,
                    ),
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
                          SamsLocaleText(
                            'Daily Essentials',
                            style: TextStyle(
                              color: SamsUiTokens.textPrimary,
                              fontSize: isDesktop ? 21 : 19,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _InfoCard(
                            backgroundColor: SamsUiTokens.primary,
                            title: 'Attendance',
                            subtitle: state.attendanceSubtitle!,
                            trailing: _AttendanceProgress(
                              value: attendanceValue,
                            ),
                            leadingIcon: Icons.fact_check_rounded,
                            child: _AttendanceMetaSection(
                              label: state.attendedClassesLabel!,
                              onMarkToday: () {
                                ModernSnackbars.show(
                                  context,
                                  message:
                                      'Today\'s attendance marked successfully.',
                                  type: ModernSnackbarType.success,
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
                            child: SamsLocaleText(
                              state.busStatusLabel!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: () {
                              ModernSnackbars.show(
                                context,
                                message:
                                    'Bus details are available in Menu > SAMS Bus.',
                                type: ModernSnackbarType.info,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _SchedulePreviewCard(
                            onTap: () {
                              context.pushNamed(AppRouteNames.calendar);
                            },
                          ),
                          const SizedBox(height: 24),
                          SamsLocaleText(
                            'Announcements',
                            style: TextStyle(
                              color: SamsUiTokens.textPrimary,
                              fontSize: isDesktop ? 21 : 19,
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
                                    ModernSnackbars.show(
                                      context,
                                      message: 'Opened: ${entry.value.title}',
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 420;
    final titleFont = SamsUiTokens.isDesktopWidth(context) ? 19.5 : 17.5;

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      SamsLocaleText(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFont,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SamsLocaleText(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: compact ? 12.8 : 13.4,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: compact ? 8 : 10),
                Flexible(
                  child: Align(alignment: Alignment.topRight, child: trailing),
                ),
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
                  SamsLocaleText(
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
                    child: SamsLocaleText(
                      badge,
                      style: const TextStyle(
                        color: SamsUiTokens.primary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SamsLocaleText(
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

class _SchedulePreviewCard extends StatelessWidget {
  const _SchedulePreviewCard({required this.onTap});

  final VoidCallback onTap;

  static const List<String> _weekdayLabels = [
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
  ];

  static const List<int> _preferredHighlights = [4, 10, 17, 24, 29];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final firstWeekdayOffset = monthStart.weekday % 7;
    final monthName = _monthLabel(now.month);
    final highlights = _preferredHighlights
        .where((day) => day <= daysInMonth)
        .take(3)
        .toList(growable: false);

    final dateLegend = [
      (
        'Exam',
        highlights.isNotEmpty ? highlights[0] : 6,
        const Color(0xFFEF4444),
      ),
      (
        'Event',
        highlights.length > 1 ? highlights[1] : 14,
        const Color(0xFFF59E0B),
      ),
      (
        'Lecture',
        highlights.length > 2 ? highlights[2] : 22,
        const Color(0xFF10B981),
      ),
    ];

    final highlightedDays = dateLegend.map((entry) => entry.$2).toSet();

    return SamsPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SamsUiTokens.radiusXl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusXl),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF063454), Color(0xFF0A4A77)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF063454).withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SamsLocaleText(
                        'Schedule',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SamsLocaleText(
                        '$monthName ${now.year}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12.6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    children: _weekdayLabels
                        .map(
                          (label) => Expanded(
                            child: Center(
                              child: SamsLocaleText(
                                label,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 6),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 1.05,
                        ),
                    itemCount:
                        ((firstWeekdayOffset + daysInMonth + 6) ~/ 7) * 7,
                    itemBuilder: (context, index) {
                      final dayValue = index - firstWeekdayOffset + 1;
                      if (dayValue < 1 || dayValue > daysInMonth) {
                        return const SizedBox.shrink();
                      }
                      final isToday = dayValue == now.day;
                      final isHighlighted = highlightedDays.contains(dayValue);

                      return _CalendarDayChip(
                        day: dayValue,
                        isToday: isToday,
                        isHighlighted: isHighlighted,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: dateLegend
                  .map(
                    (entry) => _ScheduleLegendPill(
                      label: '${entry.$1} ${entry.$2}',
                      color: entry.$3,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }

  String _monthLabel(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }
}

class _CalendarDayChip extends StatelessWidget {
  const _CalendarDayChip({
    required this.day,
    required this.isToday,
    required this.isHighlighted,
  });

  final int day;
  final bool isToday;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final Color bg = isToday
        ? const Color(0xFF063454)
        : isHighlighted
        ? const Color(0xFFEAF6FF)
        : const Color(0xFFF8FAFC);
    final Color fg = isToday
        ? Colors.white
        : isHighlighted
        ? const Color(0xFF0A4A77)
        : const Color(0xFF334155);

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isToday
              ? Colors.white.withValues(alpha: 0.2)
              : isHighlighted
              ? const Color(0xFFBDE2FF)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: SamsLocaleText(
        '$day',
        style: TextStyle(
          fontSize: 11.2,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _ScheduleLegendPill extends StatelessWidget {
  const _ScheduleLegendPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
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
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 11.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
            child: SamsLocaleText(
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
    return SamsLocaleText(
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
    final compact = MediaQuery.sizeOf(context).width < 410;

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AttendanceMeta(label: label),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: onMarkToday,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withValues(alpha: 0.76)),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.4,
                ),
              ),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
              label: const SamsLocaleText('Mark Today\'s Attendance'),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _AttendanceMeta(label: label)),
        const SizedBox(width: 12),
        SizedBox(
          height: 38,
          child: OutlinedButton.icon(
            onPressed: onMarkToday,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.76)),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.2,
              ),
            ),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 15),
            label: const SamsLocaleText('Mark Today\'s Attendance'),
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
          child: SamsLocaleText(
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
