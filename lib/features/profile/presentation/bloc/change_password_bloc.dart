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
    final validationMessage = _validatePasswords(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );

    if (validationMessage != null) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          feedbackMessage: validationMessage,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ChangePasswordStatus.submitting,
        clearFeedback: true,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 1200));

    emit(
      state.copyWith(
        status: ChangePasswordStatus.success,
        feedbackMessage: 'Password updated successfully',
      ),
    );
  }

  String? _validatePasswords({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    final current = currentPassword.trim();
    final next = newPassword.trim();
    final confirm = confirmPassword.trim();

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      return 'Please fill all password fields.';
    }

    if (next.length < 8) {
      return 'New password must be at least 8 characters.';
    }

    if (next != confirm) {
      return 'New password and confirm password do not match.';
    }

    return null;
  }

  void _onChangePasswordFeedbackCleared(
    ChangePasswordFeedbackCleared event,
    Emitter<ChangePasswordState> emit,
  ) {
    emit(state.copyWith(clearFeedback: true));
  }
}
