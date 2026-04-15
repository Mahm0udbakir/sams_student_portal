import '../../domain/entities/message_thread_entity.dart';

class MessageThreadModel extends MessageThreadEntity {
  const MessageThreadModel({
    required super.id,
    required super.name,
    required super.message,
    required super.avatarUrl,
    required super.lastSeenLabel,
    required super.isOnline,
    required super.unreadCount,
  });
}
