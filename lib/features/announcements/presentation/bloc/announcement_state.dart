part of 'announcement_bloc.dart';

enum AnnouncementStatus { initial, loading, success, failure, requiresSignIn }

class AnnouncementState extends Equatable {
  const AnnouncementState({
    this.status = AnnouncementStatus.initial,
    this.announcements = const [],
    this.errorMessage,
    this.isSigningIn = false,
  });

  final AnnouncementStatus status;
  final List<AnnouncementItem> announcements;
  final String? errorMessage;
  final bool isSigningIn;

  AnnouncementState copyWith({
    AnnouncementStatus? status,
    List<AnnouncementItem>? announcements,
    String? errorMessage,
    bool clearError = false,
    bool? isSigningIn,
  }) {
    return AnnouncementState(
      status: status ?? this.status,
      announcements: announcements ?? this.announcements,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSigningIn: isSigningIn ?? this.isSigningIn,
    );
  }

  @override
  List<Object?> get props => [status, announcements, errorMessage, isSigningIn];
}
