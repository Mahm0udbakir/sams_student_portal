part of 'help_desk_bloc.dart';

sealed class HelpDeskEvent extends Equatable {
  const HelpDeskEvent();

  @override
  List<Object?> get props => [];
}

class HelpDeskRequested extends HelpDeskEvent {
  const HelpDeskRequested();
}

class HelpDeskConcernSubmitted extends HelpDeskEvent {
  const HelpDeskConcernSubmitted({
    required this.department,
    required this.concern,
  });

  final String department;
  final String concern;

  @override
  List<Object?> get props => [department, concern];
}

class HelpDeskSubmissionNoticeCleared extends HelpDeskEvent {
  const HelpDeskSubmissionNoticeCleared();
}

class HelpDeskComplaintAdded extends HelpDeskEvent {
  const HelpDeskComplaintAdded({required this.complaint});

  final ComplaintEntity complaint;

  @override
  List<Object?> get props => [complaint];
}
