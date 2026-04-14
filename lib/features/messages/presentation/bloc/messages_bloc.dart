import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/message_thread_entity.dart';
import '../../domain/repositories/messages_repository.dart';

part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc({required MessagesRepository repository})
    : _repository = repository,
      super(const MessagesState()) {
    on<MessagesRequested>(_onMessagesRequested);
  }

  final MessagesRepository _repository;

  Future<void> _onMessagesRequested(
    MessagesRequested event,
    Emitter<MessagesState> emit,
  ) async {
    emit(state.copyWith(status: MessagesStatus.loading));
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final threads = await _repository.getThreads();
      emit(state.copyWith(status: MessagesStatus.success, threads: threads));
    } catch (_) {
      emit(
        state.copyWith(
          status: MessagesStatus.failure,
          errorMessage: 'Failed to load messages. Please try again.',
        ),
      );
    }
  }
}
