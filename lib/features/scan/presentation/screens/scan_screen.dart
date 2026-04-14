import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_pressable.dart';
import '../../data/repositories/fake_scan_repository.dart';
import '../../domain/entities/scan_option_entity.dart';
import '../bloc/scan_bloc.dart';
import '../../../../shared/widgets/sams_state_views.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  static const Color _samsPrimary = SamsUiTokens.primary;

  String _labelForKeyword(List<ScanOptionEntity> options, String keyword, String fallback) {
    for (final option in options) {
      if (option.label.toLowerCase().contains(keyword)) {
        return option.label;
      }
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScanBloc(repository: FakeScanRepository())..add(const ScanRequested()),
      child: BlocListener<ScanBloc, ScanState>(
        listenWhen: (previous, current) =>
            previous.feedbackMessage != current.feedbackMessage &&
            current.feedbackMessage != null,
        listener: (context, state) async {
          final message = state.feedbackMessage;
          if (message == null || message.isEmpty) {
            return;
          }

          if (state.status == ScanStatus.success) {
            final action = state.activeAction;
            final shouldScanAgain = await showDialog<bool>(
              context: context,
              builder: (dialogContext) {
                return Dialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFDCE5EF)),
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: SamsUiTokens.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: SamsUiTokens.success,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Scan successful',
                                style: TextStyle(
                                  color: SamsUiTokens.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          message,
                          style: const TextStyle(
                            color: SamsUiTokens.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Your request has been verified by SAMS services.',
                          style: TextStyle(
                            color: SamsUiTokens.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SamsTapScale(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(true),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: SamsUiTokens.primary),
                                    foregroundColor: SamsUiTokens.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  child: const Text('Scan again'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SamsTapScale(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: SamsUiTokens.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  child: const Text('Done'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );

            if (!context.mounted) {
              return;
            }

            if (shouldScanAgain == true) {
              if (action == ScanAction.gallery) {
                context.read<ScanBloc>().add(const ScanGalleryPicked());
              } else {
                context.read<ScanBloc>().add(const ScanStarted());
              }
            }
          } else if (state.status == ScanStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }

          context.read<ScanBloc>().add(const ScanFeedbackCleared());
        },
        child: BlocBuilder<ScanBloc, ScanState>(
          builder: (context, state) {
            final width = MediaQuery.sizeOf(context).width;
            final frameSize = (width - 68).clamp(230.0, 290.0);
            final options = state.options;
      final galleryLabel = _labelForKeyword(options, 'gallery', 'Choose from gallery');
      final cameraLabel = _labelForKeyword(options, 'photo', 'Take a photo');

            if (state.status == ScanStatus.initial || state.status == ScanStatus.loading) {
              return const Scaffold(
                backgroundColor: SamsUiTokens.scaffoldBackground,
                body: SamsLoadingView(
                  title: 'Preparing scanner',
                  message: 'Getting your camera and gallery options ready...',
                ),
              );
            }

            if (state.status == ScanStatus.failure && state.options.isEmpty) {
              return Scaffold(
                backgroundColor: SamsUiTokens.scaffoldBackground,
                appBar: AppBar(
                  title: const Text('Scan'),
                  centerTitle: true,
                ),
                body: SamsErrorState(
                  title: 'Couldn\'t open scanner',
                  message:
                      state.feedbackMessage ?? 'Failed to load scan options. Please try again.',
                  retryLabel: 'Retry',
                  onRetry: () => context.read<ScanBloc>().add(const ScanRequested()),
                ),
              );
            }

            final isProcessing = state.isProcessing;

            return Scaffold(
              backgroundColor: SamsUiTokens.scaffoldBackground,
              appBar: AppBar(
                title: const Text('Scan'),
                centerTitle: true,
              ),
              body: Stack(
                children: [
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: SamsUiTokens.pageInsets(
                        context,
                        top: 14,
                        bottom: 24,
                        regularHorizontal: 20,
                        compactHorizontal: 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            'Scan QR Code',
                            style: TextStyle(
                              color: SamsUiTokens.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (isProcessing)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Scanning in progress...',
                                style: TextStyle(
                                  color: SamsUiTokens.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          Center(
                            child: Container(
                              width: frameSize,
                              height: frameSize,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFE3E8EF)),
                                boxShadow: SamsUiTokens.cardShadow,
                              ),
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color(0xFFF8FAFD),
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.qr_code_scanner_rounded,
                                    color: SamsUiTokens.primary,
                                    size: 116,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          SizedBox(
                            width: double.infinity,
                            child: SamsTapScale(
                              enabled: !isProcessing,
                              child: TextButton(
                                onPressed: isProcessing
                                    ? null
                                    : () => context.read<ScanBloc>().add(const ScanGalleryPicked()),
                                style: TextButton.styleFrom(
                                  foregroundColor: SamsUiTokens.primary,
                                  textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                                child: Text(galleryLabel),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: SamsTapScale(
                              enabled: !isProcessing,
                              child: ElevatedButton(
                                onPressed: isProcessing
                                    ? null
                                    : () => context.read<ScanBloc>().add(const ScanStarted()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _samsPrimary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                child: Text(cameraLabel),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isProcessing)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFF052941).withValues(alpha: 0.46),
                          ),
                          child: Center(
                            child: Container(
                              width: 240,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: SamsUiTokens.cardShadow,
                                border: Border.all(color: const Color(0xFFDCE5EF)),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 28,
                                    width: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.8,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(SamsUiTokens.primary),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Scanning...',
                                    style: TextStyle(
                                      color: SamsUiTokens.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Please hold still while we verify your code.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: SamsUiTokens.textSecondary,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

