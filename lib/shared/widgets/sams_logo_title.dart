import 'package:flutter/material.dart';

import '../ui/sams_ui_tokens.dart';

class SamsLogoTitle extends StatelessWidget {
  const SamsLogoTitle({
    super.key,
    required this.title,
    this.logoSize = 24,
    this.textStyle,
    this.fallbackIconColor,
  });

  final String title;
  final double logoSize;
  final TextStyle? textStyle;
  final Color? fallbackIconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.shield_rounded,
          size: logoSize,
          color: fallbackIconColor ?? SamsUiTokens.primary,
        ),
        const SizedBox(width: 8),
        SamsLocaleText(title, style: textStyle),
      ],
    );
  }
}
