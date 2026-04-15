import 'package:flutter/material.dart';

import '../../data/repositories/fake_calendar_repository.dart';
import '../../domain/entities/calendar_schedule_item_entity.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/sams_pressable.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const int _initialPage = 1200;

  late final DateTime _today;
  late final PageController _pageController;
  late final FakeCalendarRepository _calendarRepository;

  late DateTime _visibleMonth;
  late DateTime _selectedDate;
  late Map<DateTime, List<CalendarScheduleItemEntity>> _visibleMonthSchedule;
  final Map<int, Map<DateTime, List<CalendarScheduleItemEntity>>>
  _monthScheduleCache =
      <int, Map<DateTime, List<CalendarScheduleItemEntity>>>{};

  @override
  void initState() {
    super.initState();
    _today = _dateOnly(DateTime.now());
    _pageController = PageController(initialPage: _initialPage);
    _calendarRepository = FakeCalendarRepository();
    _visibleMonth = DateTime(_today.year, _today.month, 1);
    _selectedDate = _today;
    _visibleMonthSchedule = _scheduleForMonthCached(_visibleMonth);

    if (_selectedDate.month != _visibleMonth.month ||
        _selectedDate.year != _visibleMonth.year) {
      _selectedDate = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDesktop = SamsUiTokens.isDesktopWidth(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const SamsAppBar(title: 'Calendar'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: SamsUiTokens.contentMaxWidth,
            ),
            child: ListView(
              padding: SamsUiTokens.pageInsets(context, top: 14, bottom: 24),
              children: [
                _CalendarHeaderCard(
                  monthLabel:
                      '${_monthLabel(_visibleMonth.month)} ${_visibleMonth.year}',
                  onPrevious: _goToPreviousMonth,
                  onNext: _goToNextMonth,
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.surface,
                        colorScheme.surfaceContainerHighest,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.swipe_rounded,
                              size: 15,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            SamsLocaleText(
                              'Swipe left or right to change month',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: isDesktop ? 12.8 : 11.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 332,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          itemBuilder: (context, pageIndex) {
                            final monthOffset = pageIndex - _initialPage;
                            final pageMonth = DateTime(
                              _today.year,
                              _today.month + monthOffset,
                              1,
                            );
                            final monthSchedule = _scheduleForMonthCached(
                              pageMonth,
                            );

                            return _MonthCalendarView(
                              month: pageMonth,
                              today: _today,
                              selectedDate: _selectedDate,
                              monthSchedule: monthSchedule,
                              onDayTap: (day) {
                                setState(() {
                                  _selectedDate = _dateOnly(day);
                                  _visibleMonth = DateTime(
                                    pageMonth.year,
                                    pageMonth.month,
                                    1,
                                  );
                                  _visibleMonthSchedule = monthSchedule;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _ScheduleLegend(),
                const SizedBox(height: 14),
                SamsLocaleText(
                  'Upcoming • ${_weekdayLabel(_selectedDate.weekday)}, ${_monthShortLabel(_selectedDate.month)} ${_selectedDate.day}',
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: isDesktop ? 19 : 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ..._buildSelectedDayItems(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToPreviousMonth() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _goToNextMonth() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int newPage) {
    final monthOffset = newPage - _initialPage;
    final newVisibleMonth = DateTime(
      _today.year,
      _today.month + monthOffset,
      1,
    );
    final newSchedule = _scheduleForMonthCached(newVisibleMonth);

    final isSelectedInsideVisibleMonth =
        _selectedDate.year == newVisibleMonth.year &&
        _selectedDate.month == newVisibleMonth.month;

    final int fallbackDay;
    if (newSchedule.isNotEmpty) {
      final sorted = newSchedule.keys.toList()
        ..sort((a, b) => a.day.compareTo(b.day));
      fallbackDay = sorted.first.day;
    } else {
      fallbackDay = 1;
    }

    setState(() {
      _visibleMonth = newVisibleMonth;
      _visibleMonthSchedule = newSchedule;
      _selectedDate = isSelectedInsideVisibleMonth
          ? _selectedDate
          : DateTime(newVisibleMonth.year, newVisibleMonth.month, fallbackDay);
    });
  }

  List<Widget> _buildSelectedDayItems() {
    final items =
        _visibleMonthSchedule[_selectedDate] ??
        const <CalendarScheduleItemEntity>[];

    if (items.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;

      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.72),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.event_busy_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                child: SamsLocaleText(
                  'No items planned for this date.',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return items
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ScheduleItemCard(item: item),
          ),
        )
        .toList(growable: false);
  }

  int _monthKey(DateTime month) => (month.year * 100) + month.month;

  Map<DateTime, List<CalendarScheduleItemEntity>> _scheduleForMonthCached(
    DateTime month,
  ) {
    final key = _monthKey(month);
    return _monthScheduleCache.putIfAbsent(key, () => _scheduleForMonth(month));
  }

  Map<DateTime, List<CalendarScheduleItemEntity>> _scheduleForMonth(
    DateTime month,
  ) {
    final entries = _calendarRepository.getMonthSchedule(month);
    final grouped = <DateTime, List<CalendarScheduleItemEntity>>{};

    for (final entry in entries) {
      final key = _dateOnly(entry.date);
      grouped.putIfAbsent(key, () => <CalendarScheduleItemEntity>[]).add(entry);
    }

    return grouped;
  }
}

class _CalendarHeaderCard extends StatelessWidget {
  const _CalendarHeaderCard({
    required this.monthLabel,
    required this.onPrevious,
    required this.onNext,
  });

  final String monthLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SamsUiTokens.primary, Color(0xFF0A4D78), Color(0xFF105F92)],
        ),
        borderRadius: BorderRadius.circular(22),
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
          _MonthNavButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SamsLocaleText(
                  'CALENDAR',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.66),
                    fontSize: 10.5,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                SamsLocaleText(
                  monthLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                SamsLocaleText(
                  'Exams, lectures, events & birthdays overview',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _MonthNavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _MonthCalendarView extends StatelessWidget {
  const _MonthCalendarView({
    required this.month,
    required this.today,
    required this.selectedDate,
    required this.monthSchedule,
    required this.onDayTap,
  });

  static const List<String> _weekdayLabels = <String>[
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
  ];

  final DateTime month;
  final DateTime today;
  final DateTime selectedDate;
  final Map<DateTime, List<CalendarScheduleItemEntity>> monthSchedule;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekdayOffset = month.weekday % 7;
    final gridItemCount = ((firstWeekdayOffset + daysInMonth + 6) ~/ 7) * 7;

    return Column(
      children: [
        Row(
          children: _weekdayLabels
              .map(
                (day) => Expanded(
                  child: Center(
                    child: SamsLocaleText(
                      day,
                      style: TextStyle(
                        fontSize: 10.4,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 0.92,
            ),
            itemCount: gridItemCount,
            itemBuilder: (context, index) {
              final dayValue = index - firstWeekdayOffset + 1;
              if (dayValue < 1 || dayValue > daysInMonth) {
                return const SizedBox.shrink();
              }

              final dayDate = DateTime(month.year, month.month, dayValue);
              final dayItems =
                  monthSchedule[dayDate] ??
                  const <CalendarScheduleItemEntity>[];

              final isToday =
                  dayDate.year == today.year &&
                  dayDate.month == today.month &&
                  dayDate.day == today.day;
              final isSelected =
                  dayDate.year == selectedDate.year &&
                  dayDate.month == selectedDate.month &&
                  dayDate.day == selectedDate.day;

              return _CalendarDayTile(
                dayNumber: dayValue,
                isToday: isToday,
                isSelected: isSelected,
                items: dayItems,
                onTap: () => onDayTap(dayDate),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CalendarDayTile extends StatelessWidget {
  const _CalendarDayTile({
    required this.dayNumber,
    required this.isToday,
    required this.isSelected,
    required this.items,
    required this.onTap,
  });

  final int dayNumber;
  final bool isToday;
  final bool isSelected;
  final List<CalendarScheduleItemEntity> items;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasItems = items.isNotEmpty;
    final dominantType = hasItems ? items.first.type : null;
    final dominantColor = dominantType == null
        ? colorScheme.surfaceContainerHighest
        : _colorForType(dominantType);
    final textColor = isSelected
        ? Colors.white
        : hasItems
        ? Colors.white
        : isToday
        ? colorScheme.primary
        : colorScheme.onSurface;

    return SamsPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Center(
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [SamsUiTokens.primary, Color(0xFF0A4C7A)],
                  )
                : null,
            color: isSelected
                ? null
                : hasItems
                ? dominantColor
                : colorScheme.surface,
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : isToday
                  ? SamsUiTokens.primary.withValues(alpha: 0.45)
                  : hasItems
                  ? dominantColor.withValues(alpha: 0.2)
                  : colorScheme.outlineVariant.withValues(alpha: 0.66),
            ),
            boxShadow: hasItems || isSelected
                ? [
                    BoxShadow(
                      color: (isSelected ? SamsUiTokens.primary : dominantColor)
                          .withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: SamsLocaleText(
            '$dayNumber',
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleLegend extends StatelessWidget {
  const _ScheduleLegend();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: const [
          _LegendChip(label: 'Exam', color: Color(0xFFEF4444)),
          _LegendChip(label: 'Event', color: Color(0xFF7C3AED)),
          _LegendChip(label: 'Lecture', color: Color(0xFF10B981)),
          _LegendChip(label: 'Birthday', color: Color(0xFFF59E0B)),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          SamsLocaleText(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleItemCard extends StatelessWidget {
  const _ScheduleItemCard({required this.item});

  final CalendarScheduleItemEntity item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accentColor = _colorForType(item.type);
    final icon = _iconForType(item.type);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: accentColor, size: 17.5),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SamsLocaleText(
                  item.title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.2,
                  ),
                ),
                const SizedBox(height: 2),
                SamsLocaleText(
                  '${item.timeRange} • ${item.location}',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.note != null && item.note!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  SamsLocaleText(
                    item.note!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: SamsLocaleText(
                  _compactTime(item.timeRange),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.2,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SamsLocaleText(
                    _labelForType(item.type),
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.6,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  const _MonthNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SamsPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

String _compactTime(String timeRange) {
  final start = timeRange.split('-').first.trim();
  return start;
}

Color _colorForType(CalendarEntryType type) {
  switch (type) {
    case CalendarEntryType.exam:
      return const Color(0xFFEF4444);
    case CalendarEntryType.event:
      return const Color(0xFF7C3AED);
    case CalendarEntryType.lecture:
      return const Color(0xFF10B981);
    case CalendarEntryType.birthday:
      return const Color(0xFFF59E0B);
  }
}

IconData _iconForType(CalendarEntryType type) {
  switch (type) {
    case CalendarEntryType.exam:
      return Icons.assignment_rounded;
    case CalendarEntryType.event:
      return Icons.celebration_rounded;
    case CalendarEntryType.lecture:
      return Icons.menu_book_rounded;
    case CalendarEntryType.birthday:
      return Icons.cake_rounded;
  }
}

String _labelForType(CalendarEntryType type) {
  switch (type) {
    case CalendarEntryType.exam:
      return 'Exam';
    case CalendarEntryType.event:
      return 'Event';
    case CalendarEntryType.lecture:
      return 'Lecture';
    case CalendarEntryType.birthday:
      return 'Birthday';
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String _monthLabel(int month) {
  const months = <String>[
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
  return months[month - 1];
}

String _monthShortLabel(int month) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}

String _weekdayLabel(int weekday) {
  const weekdays = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return weekdays[weekday - 1];
}
