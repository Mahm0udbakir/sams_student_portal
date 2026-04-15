import '../../../../core/data/repositories/fake_data_repository.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/message_thread_entity.dart';
import '../../domain/repositories/messages_repository.dart';
import '../models/message_thread_model.dart';

class FakeMessagesRepository implements MessagesRepository {
  FakeMessagesRepository({FakeDataRepository? dataRepository})
    : _dataRepository = dataRepository ?? const FakeDataRepository();

  final FakeDataRepository _dataRepository;

  static const Map<String, String> _avatarByThreadId = {
    'friend_1': 'https://i.pravatar.cc/200?img=12',
    'friend_2': 'https://i.pravatar.cc/200?img=47',
    'friend_3': 'https://i.pravatar.cc/200?img=32',
    'friend_4': 'https://i.pravatar.cc/200?img=20',
    'friend_5': 'https://i.pravatar.cc/200?img=33',
    'friend_6': 'https://i.pravatar.cc/200?img=15',
  };

  static const Map<String, bool> _onlineByThreadId = {
    'friend_1': true,
    'friend_2': true,
    'friend_3': false,
    'friend_4': false,
    'friend_5': true,
    'friend_6': false,
  };

  static const Map<String, int> _unreadByThreadId = {
    'friend_1': 2,
    'friend_2': 1,
    'friend_3': 0,
    'friend_4': 3,
    'friend_5': 0,
    'friend_6': 0,
  };

  static const Map<String, String> _lastSeenByThreadId = {
    'friend_1': 'Now',
    'friend_2': '5m ago',
    'friend_3': '12m ago',
    'friend_4': '1h ago',
    'friend_5': '3h ago',
    'friend_6': 'Yesterday',
  };

  static const Map<String, List<ChatMessageEntity>> _messagesByThreadId = {
    'friend_1': [
      ChatMessageEntity(
        id: 'f1_1',
        threadId: 'friend_1',
        text: 'Reminder: Accounting quiz starts at 10:00 AM.',
        sentAtLabel: '09:02',
        sentByMe: false,
      ),
      ChatMessageEntity(
        id: 'f1_2',
        threadId: 'friend_1',
        text: 'Thank you doctor, I will be there on time.',
        sentAtLabel: '09:08',
        sentByMe: true,
      ),
      ChatMessageEntity(
        id: 'f1_3',
        threadId: 'friend_1',
        text: 'Great. Bring your SAMS ID card with you.',
        sentAtLabel: '09:11',
        sentByMe: false,
      ),
    ],
    'friend_2': [
      ChatMessageEntity(
        id: 'f2_1',
        threadId: 'friend_2',
        text: 'The case study rubric is uploaded on Moodle now.',
        sentAtLabel: '08:40',
        sentByMe: false,
      ),
      ChatMessageEntity(
        id: 'f2_2',
        threadId: 'friend_2',
        text: 'Received, thank you.',
        sentAtLabel: '08:46',
        sentByMe: true,
      ),
    ],
    'friend_3': [
      ChatMessageEntity(
        id: 'f3_1',
        threadId: 'friend_3',
        text: 'Attendance will be taken in the first 15 minutes only.',
        sentAtLabel: '07:52',
        sentByMe: false,
      ),
      ChatMessageEntity(
        id: 'f3_2',
        threadId: 'friend_3',
        text: 'Noted. I will join early.',
        sentAtLabel: '07:56',
        sentByMe: true,
      ),
    ],
    'friend_4': [
      ChatMessageEntity(
        id: 'f4_1',
        threadId: 'friend_4',
        text: 'Your internship letter is ready at Building B counter 4.',
        sentAtLabel: '06:31',
        sentByMe: false,
      ),
      ChatMessageEntity(
        id: 'f4_2',
        threadId: 'friend_4',
        text: 'Perfect. Can I collect it tomorrow morning?',
        sentAtLabel: '06:38',
        sentByMe: true,
      ),
      ChatMessageEntity(
        id: 'f4_3',
        threadId: 'friend_4',
        text: 'Yes, from 9:30 AM to 2:30 PM.',
        sentAtLabel: '06:41',
        sentByMe: false,
      ),
    ],
    'friend_5': [
      ChatMessageEntity(
        id: 'f5_1',
        threadId: 'friend_5',
        text: 'MIS lab moved to Computer Lab 2 this Tuesday.',
        sentAtLabel: 'Yesterday',
        sentByMe: false,
      ),
    ],
    'friend_6': [
      ChatMessageEntity(
        id: 'f6_1',
        threadId: 'friend_6',
        text: 'Economics section will focus on Egypt inflation trends.',
        sentAtLabel: 'Yesterday',
        sentByMe: false,
      ),
      ChatMessageEntity(
        id: 'f6_2',
        threadId: 'friend_6',
        text: 'That sounds interesting, see you in class.',
        sentAtLabel: 'Yesterday',
        sentByMe: true,
      ),
    ],
  };

  @override
  Future<List<MessageThreadEntity>> getThreads() async {
    final threads = _dataRepository.getMessageThreads();

    return threads
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final item = entry.value;
          final threadId = 'friend_${index + 1}';
          return MessageThreadModel(
            id: threadId,
            name: item['name'] as String,
            message: item['message'] as String,
            avatarUrl: _avatarByThreadId[threadId] ?? '',
            lastSeenLabel: _lastSeenByThreadId[threadId] ?? 'Now',
            isOnline: _onlineByThreadId[threadId] ?? false,
            unreadCount: _unreadByThreadId[threadId] ?? 0,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<List<ChatMessageEntity>> getMessagesForThread(String threadId) async {
    return List<ChatMessageEntity>.from(
      _messagesByThreadId[threadId] ?? const [],
    );
  }
}
