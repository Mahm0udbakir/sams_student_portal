part of 'help_desk_bloc.dart';

enum HelpDeskStatus { initial, loading, success, failure }
enum HelpDeskSubmissionStatus { idle, submitting, success, failure }

class HelpDeskState extends Equatable {
  const HelpDeskState({
    this.status = HelpDeskStatus.initial,
    this.complaints = const [],
    this.submissionStatus = HelpDeskSubmissionStatus.idle,
    this.submissionMessage,
    this.errorMessage,
  });

  final HelpDeskStatus status;
  final List<ComplaintEntity> complaints;
  final HelpDeskSubmissionStatus submissionStatus;
  final String? submissionMessage;
  final String? errorMessage;

  HelpDeskState copyWith({
    HelpDeskStatus? status,
    List<ComplaintEntity>? complaints,
    HelpDeskSubmissionStatus? submissionStatus,
    String? submissionMessage,
    bool clearSubmissionMessage = false,
    String? errorMessage,
  }) {
    return HelpDeskState(
      status: status ?? this.status,
      complaints: complaints ?? this.complaints,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      submissionMessage: clearSubmissionMessage
          ? null
          : (submissionMessage ?? this.submissionMessage),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        complaints,
        submissionStatus,
        submissionMessage,
        errorMessage,
      ];
}
