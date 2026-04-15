import '../../domain/entities/calendar_schedule_item_entity.dart';

class CalendarScheduleItemModel extends CalendarScheduleItemEntity {
  const CalendarScheduleItemModel({
    required super.date,
    required super.title,
    required super.timeRange,
    required super.location,
    required super.type,
    super.note,
  });

  factory CalendarScheduleItemModel.fromMap(
    Map<String, dynamic> map, {
    required int year,
    required int month,
  }) {
    return CalendarScheduleItemModel(
      date: DateTime(year, month, map['day'] as int),
      title: map['title'] as String,
      timeRange: map['timeRange'] as String,
      location: map['location'] as String,
      note: map['note'] as String?,
      type: _typeFromRaw(map['type'] as String),
    );
  }

  static CalendarEntryType _typeFromRaw(String raw) {
    switch (raw.toLowerCase()) {
      case 'exam':
        return CalendarEntryType.exam;
      case 'event':
        return CalendarEntryType.event;
      case 'birthday':
        return CalendarEntryType.birthday;
      default:
        return CalendarEntryType.lecture;
    }
  }
}
