part of 'announcement_bloc.dart';

sealed class AnnouncementEvent extends Equatable {
  const AnnouncementEvent();

  @override
  List<Object?> get props => [];
}

class AnnouncementRequested extends AnnouncementEvent {
  const AnnouncementRequested();
}

class AnnouncementRefreshRequested extends AnnouncementEvent {
  const AnnouncementRefreshRequested();
}

class AnnouncementAnonymousSignInRequested extends AnnouncementEvent {
  const AnnouncementAnonymousSignInRequested();
}
