import '../../domain/entities/complaint_entity.dart';

class ComplaintModel extends ComplaintEntity {
  const ComplaintModel({
    required super.department,
    required super.message,
    required super.contact,
  });
}
