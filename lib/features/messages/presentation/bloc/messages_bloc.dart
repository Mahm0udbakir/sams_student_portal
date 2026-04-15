import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/message_thread_entity.dart';
import '../../domain/repositories/messages_repository.dart';

part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc({required MessagesRepository repository})
    : _repository = repository,
      super(const MessagesState()) {
    on<MessagesRequested>(_onMessagesRequested);
    on<MessagesSearchChanged>(_onMessagesSearchChanged);
    on<MessageThreadOpened>(_onMessageThreadOpened);
    on<MessageThreadClosed>(_onMessageThreadClosed);
    on<MessageSent>(_onMessageSent);
  }

  final MessagesRepository _repository;

  Future<void> _onMessagesRequested(
    MessagesRequested event,
    Emitter<MessagesState> emit,
  ) async {
    emit(state.copyWith(status: MessagesStatus.loading, clearError: true));

    try {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      final threads = await _repository.getThreads();
      emit(
        state.copyWith(
          status: MessagesStatus.success,
          threads: threads,
          visibleThreads: _applySearch(threads, state.searchQuery),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: MessagesStatus.failure,
          errorMessage: 'Failed to load messages. Please try again.',
        ),
      );
    }
  }

  void _onMessagesSearchChanged(
    MessagesSearchChanged event,
    Emitter<MessagesState> emit,
  ) {
    emit(
      state.copyWith(
        searchQuery: event.query,
        visibleThreads: _applySearch(state.threads, event.query),
      ),
    );
  }

  Future<void> _onMessageThreadOpened(
    MessageThreadOpened event,
    Emitter<MessagesState> emit,
  ) async {
    final cached = state.cachedConversations[event.thread.id];
    if (cached != null) {
      emit(
        state.copyWith(
          activeThread: event.thread,
          activeMessages: cached,
          isThreadLoading: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        activeThread: event.thread,
        activeMessages: const [],
        isThreadLoading: true,
      ),
    );

    final threadMessages = await _repository.getMessagesForThread(
      event.thread.id,
    );
    final updatedCache = Map<String, List<ChatMessageEntity>>.from(
      state.cachedConversations,
    )..[event.thread.id] = threadMessages;

    emit(
      state.copyWith(
        activeThread: event.thread,
        activeMessages: threadMessages,
        cachedConversations: updatedCache,
        isThreadLoading: false,
      ),
    );
  }

  void _onMessageThreadClosed(
    MessageThreadClosed event,
    Emitter<MessagesState> emit,
  ) {
    emit(
      state.copyWith(
        clearActiveThread: true,
        activeMessages: const [],
        isThreadLoading: false,
      ),
    );
  }

  void _onMessageSent(MessageSent event, Emitter<MessagesState> emit) {
    final activeThread = state.activeThread;
    final text = event.text.trim();

    if (activeThread == null || text.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final message = ChatMessageEntity(
      id: 'local_${now.microsecondsSinceEpoch}',
      threadId: activeThread.id,
      text: text,
      sentAtLabel:
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      sentByMe: true,
    );

    final updatedMessages = [...state.activeMessages, message];
    final refreshedThread = activeThread.copyWith(
      message: text,
      unreadCount: 0,
      lastSeenLabel: 'Now',
    );

    final updatedThreads = _moveThreadToTop(refreshedThread, state.threads);

    final updatedCache = Map<String, List<ChatMessageEntity>>.from(
      state.cachedConversations,
    )..[activeThread.id] = updatedMessages;

    emit(
      state.copyWith(
        threads: updatedThreads,
        visibleThreads: _applySearch(updatedThreads, state.searchQuery),
        activeThread: refreshedThread,
        activeMessages: updatedMessages,
        cachedConversations: updatedCache,
      ),
    );
  }

  List<MessageThreadEntity> _applySearch(
    List<MessageThreadEntity> source,
    String query,
  ) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return source;
    }

    return source
        .where((thread) {
          final haystack = '${thread.name} ${thread.message}'.toLowerCase();
          return haystack.contains(trimmed);
        })
        .toList(growable: false);
  }

  List<MessageThreadEntity> _moveThreadToTop(
    MessageThreadEntity thread,
    List<MessageThreadEntity> source,
  ) {
    final copied = [...source.where((item) => item.id != thread.id)];
    copied.insert(0, thread);
    return copied;
  }
}
