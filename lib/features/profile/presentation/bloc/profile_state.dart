part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.overview,
    this.errorMessage,
  });

  final ProfileStatus status;
  final ProfileOverviewEntity? overview;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileOverviewEntity? overview,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, overview, errorMessage];
}
