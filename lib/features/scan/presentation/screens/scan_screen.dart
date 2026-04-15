import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../../shared/ui/sams_lottie_assets.dart';
import '../../../../shared/ui/sams_ui_tokens.dart';
import '../../../../shared/widgets/sams_app_bar.dart';
import '../../../../shared/widgets/modern_snackbar.dart';
import '../../../../shared/widgets/sams_pressable.dart';
import '../../data/repositories/fake_scan_repository.dart';
import '../../domain/entities/scan_option_entity.dart';
import '../bloc/scan_bloc.dart';
import '../../../../shared/widgets/sams_state_views.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  static const Color _samsPrimary = SamsUiTokens.primary;

  bool _hasOption(List<ScanOptionEntity> options, String keyword) {
    return options.any(
      (option) => option.label.toLowerCase().contains(keyword),
    );
  }

  Future<bool?> _showSuccessDialog(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.72),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.24),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF063454), Color(0xFF0A5A88)],
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Color(0xFFD7E9FB),
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      SamsLocaleText(
                        'Scan successful',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          width: 84,
                          height: 84,
                          child: RepaintBoundary(
                            child: Lottie.asset(
                              SamsLottieAssets.successCheckLight,
                              repeat: false,
                              animate: true,
                              frameRate: FrameRate.composition,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.low,
                              addRepaintBoundary: true,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.check_circle_rounded,
                                color: SamsUiTokens.success,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SamsLocaleText(
                        message,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const SamsLocaleText(
                        'Your request has been verified by SAMS services.',
                        style: TextStyle(
                          color: SamsUiTokens.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: SamsTapScale(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: SamsUiTokens.primary,
                                  ),
                                  foregroundColor: SamsUiTokens.primary,
                                  minimumSize: const Size.fromHeight(44),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                child: const SamsLocaleText('Scan again'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SamsTapScale(
                              child: ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SamsUiTokens.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(44),
                                  elevation: 0,
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                child: const SamsLocaleText('Done'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ScanBloc(repository: FakeScanRepository())
            ..add(const ScanRequested()),
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
            final shouldScanAgain = await _showSuccessDialog(context, message);

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
            ModernSnackbars.show(
              context,
              message: message,
              type: ModernSnackbarType.error,
            );
          }

          context.read<ScanBloc>().add(const ScanFeedbackCleared());
        },
        child: BlocBuilder<ScanBloc, ScanState>(
          buildWhen: (previous, current) {
            return previous.status != current.status ||
                previous.options != current.options ||
                previous.activeAction != current.activeAction ||
                previous.feedbackMessage != current.feedbackMessage;
          },
          builder: (context, state) {
            final width = MediaQuery.sizeOf(context).width;
            final frameSize = (width - 72).clamp(236.0, 310.0);
            final options = state.options;
            final canUseGallery = _hasOption(options, 'gallery');
            final canUseCamera =
                _hasOption(options, 'camera') || _hasOption(options, 'photo');

            if (state.status == ScanStatus.initial ||
                state.status == ScanStatus.loading) {
              return Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: SamsLoadingView(
                  title: 'Preparing scanner',
                  message: 'Getting your camera and gallery options ready...',
                ),
              );
            }

            if (state.status == ScanStatus.failure && state.options.isEmpty) {
              return Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                appBar: const SamsAppBar(title: 'Scan'),
                body: SamsErrorState(
                  title: 'Couldn\'t open scanner',
                  message:
                      state.feedbackMessage ??
                      'Failed to load scan options. Please try again.',
                  retryLabel: 'Retry',
                  onRetry: () =>
                      context.read<ScanBloc>().add(const ScanRequested()),
                ),
              );
            }

            final isProcessing = state.isProcessing;

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: const SamsAppBar(title: 'Scan'),
              body: Stack(
                children: [
                  const Positioned(
                    top: -88,
                    right: -72,
                    child: _ScanBackdropBubble(),
                  ),
                  const Positioned(
                    bottom: 110,
                    left: -82,
                    child: _ScanBackdropBubble(),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: SamsUiTokens.pageInsets(
                        context,
                        top: 14,
                        bottom: 18,
                        regularHorizontal: 20,
                        compactHorizontal: 14,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            children: [
                              const _ScanHeroCard(),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Center(
                                  child: _ScannerFrame(
                                    size: frameSize,
                                    isProcessing: isProcessing,
                                  ),
                                ),
                              ),
                              if (isProcessing)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8, bottom: 6),
                                  child: SamsLocaleText(
                                    'Scanning in progress...',
                                    style: TextStyle(
                                      color: SamsUiTokens.textSecondary,
                                      fontSize: 12.8,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: SamsTapScale(
                                      enabled: !isProcessing && canUseGallery,
                                      child: OutlinedButton.icon(
                                        onPressed:
                                            (isProcessing || !canUseGallery)
                                            ? null
                                            : () =>
                                                  context.read<ScanBloc>().add(
                                                    const ScanGalleryPicked(),
                                                  ),
                                        icon: const Icon(
                                          Icons.photo_library_rounded,
                                        ),
                                        label: const SamsLocaleText(
                                          'Choose from gallery',
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: _samsPrimary,
                                          side: const BorderSide(
                                            color: _samsPrimary,
                                            width: 1.1,
                                          ),
                                          minimumSize: const Size.fromHeight(
                                            50,
                                          ),
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13.6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: SamsTapScale(
                                      enabled: !isProcessing && canUseCamera,
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            (isProcessing || !canUseCamera)
                                            ? null
                                            : () => context
                                                  .read<ScanBloc>()
                                                  .add(const ScanStarted()),
                                        icon: const Icon(
                                          Icons.camera_alt_rounded,
                                        ),
                                        label: const SamsLocaleText(
                                          'Use camera',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _samsPrimary,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          minimumSize: const Size.fromHeight(
                                            50,
                                          ),
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13.8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const SamsLocaleText(
                                'Please hold still while we verify your code.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: SamsUiTokens.textSecondary,
                                  fontSize: 12.3,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  if (isProcessing) const _ProcessingOverlayCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ScanHeroCard extends StatelessWidget {
  const _ScanHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF063454), Color(0xFF0A5F93)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF063454).withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.qr_code_2_rounded, color: Color(0xFFD9EBFB)),
              SizedBox(width: 8),
              SamsLocaleText(
                'Scan QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          SamsLocaleText(
            'Please hold still while we verify your code.',
            style: TextStyle(
              color: Color(0xFFE1ECF8),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.32,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame({required this.size, required this.isProcessing});

  final double size;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A5A88), Color(0xFF1E88E5)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A4D78).withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.64),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0A4D78).withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.qr_code_scanner_rounded,
                color: SamsUiTokens.primary,
                size: 120,
              ),
            ),
            const _FrameCorner(alignment: Alignment.topLeft),
            const _FrameCorner(alignment: Alignment.topRight),
            const _FrameCorner(alignment: Alignment.bottomLeft),
            const _FrameCorner(alignment: Alignment.bottomRight),
            if (isProcessing)
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 720),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: 0.16 + (value * 0.16),
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF0A4D78),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FrameCorner extends StatelessWidget {
  const _FrameCorner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isTop =
        alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isBottom =
        alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight;
    final isLeft =
        alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;
    final isRight =
        alignment == Alignment.topRight || alignment == Alignment.bottomRight;

    return Align(
      alignment: alignment,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.all(14),
        child: Stack(
          children: [
            if (isTop)
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A5A88),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            if (isBottom)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A5A88),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            if (isLeft)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 3,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A5A88),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            if (isRight)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 3,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A5A88),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProcessingOverlayCard extends StatelessWidget {
  const _ProcessingOverlayCard();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF052941).withValues(alpha: 0.44),
          ),
          child: Center(
            child: Container(
              width: 244,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.72),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        SamsUiTokens.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SamsLocaleText(
                    'Scanning...',
                    style: TextStyle(
                      color: SamsUiTokens.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  SamsLocaleText(
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
    );
  }
}

class _ScanBackdropBubble extends StatelessWidget {
  const _ScanBackdropBubble();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
