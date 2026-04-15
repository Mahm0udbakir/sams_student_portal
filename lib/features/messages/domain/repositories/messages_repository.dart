import '../entities/chat_message_entity.dart';
import '../entities/message_thread_entity.dart';

abstract class MessagesRepository {
  Future<List<MessageThreadEntity>> getThreads();

  Future<List<ChatMessageEntity>> getMessagesForThread(String threadId);
}
