part of 'messages_bloc.dart';

enum MessagesStatus { initial, loading, success, failure }

class MessagesState extends Equatable {
  const MessagesState({
    this.status = MessagesStatus.initial,
    this.threads = const [],
    this.errorMessage,
  });

  final MessagesStatus status;
  final List<MessageThreadEntity> threads;
  final String? errorMessage;

  MessagesState copyWith({
    MessagesStatus? status,
    List<MessageThreadEntity>? threads,
    String? errorMessage,
  }) {
    return MessagesState(
      status: status ?? this.status,
      threads: threads ?? this.threads,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, threads, errorMessage];
}
