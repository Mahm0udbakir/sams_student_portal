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
    final colorScheme = Theme.of(context).colorScheme;

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
            SamsLocaleText(
              title,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            SamsLocaleText(
              message,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.36 : 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: SamsUiTokens.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: SamsUiTokens.primary, size: 30),
              ),
              const SizedBox(height: 12),
              SamsLocaleText(
                title,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              SamsLocaleText(
                message,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
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
                    child: SamsLocaleText(retryLabel),
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerWidget(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(radius),
      baseColor: isDark
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.98)
          : const Color(0xFFE2ECF5),
      highlightColor: SamsUiTokens.primary.withValues(alpha: 0.18),
    );
  }
}
