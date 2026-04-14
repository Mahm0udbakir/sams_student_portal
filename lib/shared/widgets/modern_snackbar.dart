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
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    return messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
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

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF5F8FD)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A001728),
            blurRadius: 16,
            offset: Offset(0, 6),
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
            child: Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: SamsUiTokens.textPrimary,
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
