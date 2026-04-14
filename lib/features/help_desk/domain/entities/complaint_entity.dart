import 'package:equatable/equatable.dart';

class ComplaintEntity extends Equatable {
  const ComplaintEntity({
    required this.department,
    required this.message,
    required this.contact,
  });

  final String department;
  final String message;
  final String contact;

  @override
  List<Object?> get props => [department, message, contact];
}
