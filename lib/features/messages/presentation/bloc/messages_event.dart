part of 'messages_bloc.dart';

sealed class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object?> get props => [];
}

class MessagesRequested extends MessagesEvent {
  const MessagesRequested();
}
