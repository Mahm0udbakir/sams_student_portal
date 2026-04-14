import '../entities/scan_option_entity.dart';

abstract class ScanRepository {
  Future<List<ScanOptionEntity>> getOptions();
}
