import '../entities/complaint_entity.dart';

abstract class HelpDeskRepository {
  Future<List<ComplaintEntity>> getComplaints();
}
