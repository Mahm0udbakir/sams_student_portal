import '../../../../core/data/repositories/fake_data_repository.dart';
import '../../domain/entities/message_thread_entity.dart';
import '../../domain/repositories/messages_repository.dart';
import '../models/message_thread_model.dart';

class FakeMessagesRepository implements MessagesRepository {
  FakeMessagesRepository({FakeDataRepository? dataRepository})
    : _dataRepository = dataRepository ?? const FakeDataRepository();

  final FakeDataRepository _dataRepository;

  @override
  Future<List<MessageThreadEntity>> getThreads() async {
    final threads = _dataRepository.getMessageThreads();

    return threads
        .map(
          (item) => MessageThreadModel(
            name: item['name'] as String,
            message: item['message'] as String,
          ),
        )
        .toList(growable: false);
  }
}
