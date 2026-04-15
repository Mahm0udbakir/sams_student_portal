import 'package:flutter/material.dart';

import '../ui/sams_ui_tokens.dart';

enum ModernSnackbarType { success, error, info, warning }

class ModernSnackbars {
  const ModernSnackbars._();

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String message,
    ModernSnackbarType type = ModernSnackbarType.info,
    IconData? icon,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalMargin = width >= SamsUiTokens.desktopBreakpoint
        ? (width * 0.2).clamp(24.0, 260.0)
        : 14.0;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    return messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 14),
        duration: duration,
        content: ModernSnackbar(message: message, type: type, icon: icon),
      ),
    );
  }
}

class ModernSnackbar extends StatelessWidget {
  const ModernSnackbar({
    super.key,
    required this.message,
    this.type = ModernSnackbarType.info,
    this.icon,
  });

  final String message;
  final ModernSnackbarType type;
  final IconData? icon;

  Color _accentForType() {
    switch (type) {
      case ModernSnackbarType.success:
        return SamsUiTokens.success;
      case ModernSnackbarType.error:
        return SamsUiTokens.danger;
      case ModernSnackbarType.warning:
        return SamsUiTokens.warning;
      case ModernSnackbarType.info:
        return SamsUiTokens.primary;
    }
  }

  IconData _defaultIconForType() {
    switch (type) {
      case ModernSnackbarType.success:
        return Icons.check_circle_rounded;
      case ModernSnackbarType.error:
        return Icons.error_rounded;
      case ModernSnackbarType.warning:
        return Icons.warning_amber_rounded;
      case ModernSnackbarType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentForType();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [colorScheme.surfaceContainerHighest, colorScheme.surface]
              : const [Color(0xFFFFFFFF), Color(0xFFF5F8FD)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon ?? _defaultIconForType(), color: accent, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SamsLocaleText(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 12.9,
                fontWeight: FontWeight.w700,
                height: 1.28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
