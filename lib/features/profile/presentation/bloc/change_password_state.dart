part of 'change_password_bloc.dart';

enum ChangePasswordStatus { initial, submitting, success, failure }

class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.status = ChangePasswordStatus.initial,
    this.feedbackMessage,
  });

  final ChangePasswordStatus status;
  final String? feedbackMessage;

  bool get isSubmitting => status == ChangePasswordStatus.submitting;
  bool get isSuccess => status == ChangePasswordStatus.success;

  ChangePasswordState copyWith({
    ChangePasswordStatus? status,
    String? feedbackMessage,
    bool clearFeedback = false,
  }) {
    return ChangePasswordState(
      status: status ?? this.status,
      feedbackMessage: clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
    );
  }

  @override
  List<Object?> get props => [status, feedbackMessage];
}
