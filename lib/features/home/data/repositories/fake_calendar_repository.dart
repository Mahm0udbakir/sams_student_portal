import '../../../../core/data/repositories/fake_data_repository.dart';
import '../../domain/entities/calendar_schedule_item_entity.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../models/calendar_schedule_item_model.dart';

class FakeCalendarRepository implements CalendarRepository {
  FakeCalendarRepository({FakeDataRepository? dataRepository})
    : _dataRepository = dataRepository ?? const FakeDataRepository();

  final FakeDataRepository _dataRepository;

  @override
  List<CalendarScheduleItemEntity> getMonthSchedule(DateTime month) {
    final rawItems = _dataRepository.getCalendarSchedule(
      year: month.year,
      month: month.month,
    );

    return rawItems
        .map(
          (item) => CalendarScheduleItemModel.fromMap(
            item,
            year: month.year,
            month: month.month,
          ),
        )
        .toList(growable: false);
  }
}
