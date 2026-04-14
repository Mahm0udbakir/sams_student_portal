import 'package:flutter/material.dart';

class SamsUiTokens {
  static const Color primary = Color(0xFF063454);
  static const Color brandRed = Color(0xFFA90F2A);
  static const Color secondary = Color(0xFF1E88E5);
  static const Color accent = Color(0xFF0AA7A7);

  static const Color success = Color(0xFF0E8F54);
  static const Color warning = Color(0xFFB7791F);
  static const Color danger = Color(0xFFC0352B);

  static const Color background = Color(0xFFF5F8FC);
  static const Color scaffoldBackground = Color(0xFFF4F6FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFD9E1EA);

  static const double pageHPadding = 16;
  static const double sectionGap = 18;
  static const double cardGap = 12;

  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 22;

  static const double buttonHeight = 48;
  static const double navBarHeight = 66;
  static const double navBarCompactHeight = 62;
  static const double navTopRadius = 22;

  static const Duration fastAnimation = Duration(milliseconds: 180);
  static const Duration pageAnimation = Duration(milliseconds: 280);

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x14091C2B), blurRadius: 14, offset: Offset(0, 5)),
  ];

  static const List<BoxShadow> softTopShadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, -4)),
  ];

  static bool isCompactWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 360;
  }

  static double horizontalPagePadding(
    BuildContext context, {
    double regular = pageHPadding,
    double compact = 12,
  }) {
    return isCompactWidth(context) ? compact : regular;
  }

  static EdgeInsets pageInsets(
    BuildContext context, {
    double top = 14,
    double bottom = 20,
    double regularHorizontal = pageHPadding,
    double compactHorizontal = 12,
  }) {
    final horizontal = horizontalPagePadding(
      context,
      regular: regularHorizontal,
      compact: compactHorizontal,
    );

    return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
  }
}
