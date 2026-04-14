import 'package:flutter/material.dart';

import '../ui/sams_ui_tokens.dart';
import 'sams_pressable.dart';
import 'shimmer_widget.dart';

class SamsLoadingView extends StatelessWidget {
  const SamsLoadingView({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: SamsUiTokens.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: ShimmerWidget.circle(
                  size: 30,
                  baseColor: SamsUiTokens.primary.withValues(alpha: 0.15),
                  highlightColor: SamsUiTokens.primary.withValues(alpha: 0.34),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: SamsUiTokens.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: SamsUiTokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(
                color: SamsUiTokens.textSecondary,
                fontSize: 12.8,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SamsErrorState extends StatelessWidget {
  const SamsErrorState({
    super.key,
    required this.title,
    required this.message,
    this.retryLabel = 'Try again',
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
            border: Border.all(color: SamsUiTokens.divider),
            boxShadow: SamsUiTokens.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFFCC2D2D), size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: SamsUiTokens.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                message,
                style: const TextStyle(
                  color: SamsUiTokens.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 14),
                SamsTapScale(
                  child: ElevatedButton(
                    onPressed: onRetry,
                    child: Text(retryLabel),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SamsSkeletonBox extends StatelessWidget {
  const SamsSkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.radius = 10,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(radius),
      baseColor: const Color(0xFFE2ECF5),
      highlightColor: SamsUiTokens.primary.withValues(alpha: 0.18),
    );
  }
}
