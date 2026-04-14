part of 'scan_bloc.dart';

sealed class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object?> get props => [];
}

class ScanRequested extends ScanEvent {
  const ScanRequested();
}

class ScanStarted extends ScanEvent {
  const ScanStarted();
}

class ScanGalleryPicked extends ScanEvent {
  const ScanGalleryPicked();
}

class ScanFeedbackCleared extends ScanEvent {
  const ScanFeedbackCleared();
}
