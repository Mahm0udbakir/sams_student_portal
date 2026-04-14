import '../entities/message_thread_entity.dart';

abstract class MessagesRepository {
  Future<List<MessageThreadEntity>> getThreads();
}
