part of 'change_password_bloc.dart';

sealed class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object?> get props => [];
}

class ChangePasswordSubmitted extends ChangePasswordEvent {
  const ChangePasswordSubmitted({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];
}

class ChangePasswordFeedbackCleared extends ChangePasswordEvent {
  const ChangePasswordFeedbackCleared();
}
