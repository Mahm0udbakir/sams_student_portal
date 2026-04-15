part of 'messages_bloc.dart';

sealed class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object?> get props => [];
}

class MessagesRequested extends MessagesEvent {
  const MessagesRequested();
}

class MessagesSearchChanged extends MessagesEvent {
  const MessagesSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class MessageThreadOpened extends MessagesEvent {
  const MessageThreadOpened(this.thread);

  final MessageThreadEntity thread;

  @override
  List<Object?> get props => [thread];
}

class MessageThreadClosed extends MessagesEvent {
  const MessageThreadClosed();
}

class MessageSent extends MessagesEvent {
  const MessageSent(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}
