part of 'messages_bloc.dart';

enum MessagesStatus { initial, loading, success, failure }

class MessagesState extends Equatable {
  const MessagesState({
    this.status = MessagesStatus.initial,
    this.threads = const [],
    this.visibleThreads = const [],
    this.searchQuery = '',
    this.activeThread,
    this.activeMessages = const [],
    this.cachedConversations = const {},
    this.isThreadLoading = false,
    this.errorMessage,
  });

  final MessagesStatus status;
  final List<MessageThreadEntity> threads;
  final List<MessageThreadEntity> visibleThreads;
  final String searchQuery;
  final MessageThreadEntity? activeThread;
  final List<ChatMessageEntity> activeMessages;
  final Map<String, List<ChatMessageEntity>> cachedConversations;
  final bool isThreadLoading;
  final String? errorMessage;

  MessagesState copyWith({
    MessagesStatus? status,
    List<MessageThreadEntity>? threads,
    List<MessageThreadEntity>? visibleThreads,
    String? searchQuery,
    MessageThreadEntity? activeThread,
    bool clearActiveThread = false,
    List<ChatMessageEntity>? activeMessages,
    Map<String, List<ChatMessageEntity>>? cachedConversations,
    bool? isThreadLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MessagesState(
      status: status ?? this.status,
      threads: threads ?? this.threads,
      visibleThreads: visibleThreads ?? this.visibleThreads,
      searchQuery: searchQuery ?? this.searchQuery,
      activeThread: clearActiveThread
          ? null
          : (activeThread ?? this.activeThread),
      activeMessages: activeMessages ?? this.activeMessages,
      cachedConversations: cachedConversations ?? this.cachedConversations,
      isThreadLoading: isThreadLoading ?? this.isThreadLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    threads,
    visibleThreads,
    searchQuery,
    activeThread,
    activeMessages,
    cachedConversations,
    isThreadLoading,
    errorMessage,
  ];
}
