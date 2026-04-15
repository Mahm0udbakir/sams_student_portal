import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../ui/sams_lottie_assets.dart';
import '../ui/sams_ui_tokens.dart';
import 'sams_pressable.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
    this.maxWidth = 420,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.82),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      SamsUiTokens.primary.withValues(alpha: 0.14),
                      const Color(0xFF0C5A8D).withValues(alpha: 0.2),
                    ],
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: SamsUiTokens.primary.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Icon(icon, color: SamsUiTokens.primary, size: 34),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 94,
                height: 94,
                child: RepaintBoundary(
                  child: Lottie.asset(
                    SamsLottieAssets.emptyStateLight,
                    repeat: true,
                    animate: true,
                    frameRate: FrameRate.composition,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.low,
                    addRepaintBoundary: true,
                    errorBuilder: (_, __, ___) => Icon(
                      icon,
                      color: SamsUiTokens.primary.withValues(alpha: 0.85),
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SamsLocaleText(
                title,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              SamsLocaleText(
                subtitle,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 14),
                SamsTapScale(
                  child: ElevatedButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: SamsLocaleText(actionLabel!),
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
