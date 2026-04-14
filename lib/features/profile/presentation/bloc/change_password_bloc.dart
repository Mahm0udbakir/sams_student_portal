import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc() : super(const ChangePasswordState()) {
    on<ChangePasswordSubmitted>(_onChangePasswordSubmitted);
    on<ChangePasswordFeedbackCleared>(_onChangePasswordFeedbackCleared);
  }

  Future<void> _onChangePasswordSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    final current = event.currentPassword.trim();
    final next = event.newPassword.trim();
    final confirm = event.confirmPassword.trim();

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          feedbackMessage: 'Please fill all password fields.',
        ),
      );
      return;
    }

    if (next.length < 8) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          feedbackMessage: 'New password must be at least 8 characters.',
        ),
      );
      return;
    }

    if (next != confirm) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          feedbackMessage: 'New password and confirm password do not match.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: ChangePasswordStatus.submitting, clearFeedback: true));

  await Future<void>.delayed(const Duration(milliseconds: 1200));

    emit(
      state.copyWith(
        status: ChangePasswordStatus.success,
        feedbackMessage: 'Password updated successfully',
      ),
    );
  }

  void _onChangePasswordFeedbackCleared(
    ChangePasswordFeedbackCleared event,
    Emitter<ChangePasswordState> emit,
  ) {
    emit(state.copyWith(clearFeedback: true));
  }
}
