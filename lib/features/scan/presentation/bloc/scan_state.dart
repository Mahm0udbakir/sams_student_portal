part of 'scan_bloc.dart';

enum ScanStatus { initial, loading, ready, processing, success, failure }

enum ScanAction { none, camera, gallery }

class ScanState extends Equatable {
  const ScanState({
    this.status = ScanStatus.initial,
    this.options = const [],
    this.activeAction = ScanAction.none,
    this.feedbackMessage,
  });

  final ScanStatus status;
  final List<ScanOptionEntity> options;
  final ScanAction activeAction;
  final String? feedbackMessage;

  bool get isProcessing => status == ScanStatus.processing;

  ScanState copyWith({
    ScanStatus? status,
    List<ScanOptionEntity>? options,
    ScanAction? activeAction,
    String? feedbackMessage,
    bool clearFeedback = false,
  }) {
    return ScanState(
      status: status ?? this.status,
      options: options ?? this.options,
      activeAction: activeAction ?? this.activeAction,
      feedbackMessage: clearFeedback
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
    );
  }

  @override
  List<Object?> get props => [status, options, activeAction, feedbackMessage];
}
