import '../entities/hostel_menu_item_entity.dart';

abstract class HostelRepository {
  Future<List<HostelMenuItemEntity>> getMenuItems();
}
