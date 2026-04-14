import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/ui/sams_ui_tokens.dart';
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
            await showDialog<void>(
              context: context,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0x1F0E8F54),
                        child: Icon(Icons.check_rounded, color: SamsUiTokens.success),
                      ),
                      SizedBox(width: 10),
                      Text('Success'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: const TextStyle(
                          color: SamsUiTokens.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Your scan has been processed successfully.',
                        style: TextStyle(
                          color: SamsUiTokens.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );

            if (!context.mounted) {
              return;
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
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
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
                        ],
                      ),
                    ),
                  ),
                  if (isProcessing)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.28),
                          ),
                          child: const SamsLoadingView(
                            title: 'Processing scan',
                            message: 'Analyzing QR and verifying your request...',
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

