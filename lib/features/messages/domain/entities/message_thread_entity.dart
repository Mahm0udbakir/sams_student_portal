import 'package:equatable/equatable.dart';

class MessageThreadEntity extends Equatable {
  const MessageThreadEntity({required this.name, required this.message});

  final String name;
  final String message;

  @override
  List<Object?> get props => [name, message];
}
