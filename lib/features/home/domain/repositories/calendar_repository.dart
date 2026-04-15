import '../entities/calendar_schedule_item_entity.dart';

abstract class CalendarRepository {
  List<CalendarScheduleItemEntity> getMonthSchedule(DateTime month);
}
