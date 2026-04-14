import 'package:flutter/material.dart';

import '../../shared/ui/sams_ui_tokens.dart';

class AppTheme {
  static const Color primary = SamsUiTokens.primary;
  static const Color secondary = SamsUiTokens.secondary;
  static const Color background = SamsUiTokens.background;
  static const Color surface = SamsUiTokens.surface;

  static final ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFDCEBFA),
    onPrimaryContainer: const Color(0xFF04263D),
    secondary: secondary,
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFDDEBFF),
    onSecondaryContainer: const Color(0xFF0C2B55),
    tertiary: const Color(0xFF00A8A8),
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFCCF5F5),
    onTertiaryContainer: const Color(0xFF003D3D),
    error: const Color(0xFFB3261E),
    onError: Colors.white,
    errorContainer: const Color(0xFFF9DEDC),
    onErrorContainer: const Color(0xFF410E0B),
    surface: surface,
    onSurface: const Color(0xFF1A1C1E),
    surfaceContainerHighest: const Color(0xFFE8EEF4),
    onSurfaceVariant: const Color(0xFF43474E),
    outline: const Color(0xFF73777F),
    outlineVariant: const Color(0xFFC3C7CF),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: const Color(0xFF2E3135),
    onInverseSurface: const Color(0xFFF0F1F3),
    inversePrimary: const Color(0xFFA9C9EA),
    surfaceTint: primary,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: SamsUiTokens.scaffoldBackground,
      brightness: Brightness.light,
      fontFamily: null, // use system default font
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        hintStyle: TextStyle(color: _lightColorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: _lightColorScheme.onSurfaceVariant),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusMd),
          borderSide: const BorderSide(color: SamsUiTokens.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusMd),
          borderSide: BorderSide(color: _lightColorScheme.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusMd),
          borderSide: BorderSide(color: _lightColorScheme.error),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
          side: BorderSide(
            color: _lightColorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(SamsUiTokens.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SamsUiTokens.radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size.fromHeight(SamsUiTokens.buttonHeight),
          side: BorderSide(color: primary.withValues(alpha: 0.4), width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SamsUiTokens.radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SamsUiTokens.radiusMd),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _lightColorScheme.primary,
        unselectedItemColor: _lightColorScheme.onSurfaceVariant,
        selectedIconTheme: const IconThemeData(size: 24),
        unselectedIconTheme: const IconThemeData(size: 22),
        showUnselectedLabels: true,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: SamsUiTokens.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          color: SamsUiTokens.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: SamsUiTokens.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: SamsUiTokens.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
        bodyMedium: TextStyle(
          color: SamsUiTokens.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
        bodySmall: TextStyle(
          color: SamsUiTokens.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        indicatorColor: primary.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? primary : const Color(0xFF7A8694),
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 12,
            color: isSelected ? primary : const Color(0xFF7A8694),
          );
        }),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
