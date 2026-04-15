import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  const ChatMessageEntity({
    required this.id,
    required this.threadId,
    required this.text,
    required this.sentAtLabel,
    required this.sentByMe,
  });

  final String id;
  final String threadId;
  final String text;
  final String sentAtLabel;
  final bool sentByMe;

  @override
  List<Object?> get props => [id, threadId, text, sentAtLabel, sentByMe];
}
