import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/ui/sams_ui_tokens.dart';

class AppTheme {
  static const Color primary = SamsUiTokens.primary;
  static const Color secondary = SamsUiTokens.secondary;
  static const Color background = SamsUiTokens.background;
  static const Color surface = SamsUiTokens.surface;
  static const Color _darkScaffold = Color(0xFF0C131A);
  static const Color _darkSurface = Color(0xFF141D26);
  static const Color _darkSurfaceRaised = Color(0xFF1A2631);
  static const Color _darkNavSurface = Color(0xFF101A23);

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

  static final ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFF0E466F),
    onPrimaryContainer: const Color(0xFFD9ECFF),
    secondary: const Color(0xFF84C0EB),
    onSecondary: const Color(0xFF04253F),
    secondaryContainer: const Color(0xFF16354D),
    onSecondaryContainer: const Color(0xFFD8EBFF),
    tertiary: const Color(0xFF67D6D6),
    onTertiary: const Color(0xFF003737),
    tertiaryContainer: const Color(0xFF0A4E50),
    onTertiaryContainer: const Color(0xFFB7F2F2),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    surface: _darkSurface,
    onSurface: const Color(0xFFE6EDF4),
    surfaceContainerHighest: _darkSurfaceRaised,
    onSurfaceVariant: const Color(0xFFB2C1CE),
    outline: const Color(0xFF73879A),
    outlineVariant: const Color(0xFF2F3F4F),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: const Color(0xFFE6EDF4),
    onInverseSurface: const Color(0xFF17212A),
    inversePrimary: const Color(0xFF6EAED9),
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
        toolbarHeight: 68,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: const Color(0x30000000),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
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
          minimumSize: const Size(0, SamsUiTokens.buttonHeight),
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
          minimumSize: const Size(0, SamsUiTokens.buttonHeight),
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
      dividerTheme: DividerThemeData(
        color: _lightColorScheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: _lightColorScheme.onSurfaceVariant,
        textColor: _lightColorScheme.onSurface,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _lightColorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: _lightColorScheme.onInverseSurface),
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
          fontSize: 15.2,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: SamsUiTokens.textPrimary,
          fontSize: 14.2,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
        bodyMedium: TextStyle(
          color: SamsUiTokens.textPrimary,
          fontSize: 13.2,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
        bodySmall: TextStyle(
          color: SamsUiTokens.textSecondary,
          fontSize: 12.2,
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

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      scaffoldBackgroundColor: _darkScaffold,
      brightness: Brightness.dark,
      fontFamily: null,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        toolbarHeight: 68,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: const Color(0x66000000),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurfaceRaised,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        hintStyle: TextStyle(color: _darkColorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: _darkColorScheme.onSurfaceVariant),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusMd),
          borderSide: BorderSide(
            color: _darkColorScheme.outlineVariant.withValues(alpha: 0.8),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusMd),
          borderSide: BorderSide(color: _darkColorScheme.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusMd),
          borderSide: BorderSide(color: _darkColorScheme.error),
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkSurfaceRaised,
        elevation: 0,
        shadowColor: Colors.black45,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
          side: BorderSide(
            color: _darkColorScheme.outlineVariant.withValues(alpha: 0.84),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, SamsUiTokens.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SamsUiTokens.radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkColorScheme.primary,
          minimumSize: const Size(0, SamsUiTokens.buttonHeight),
          side: BorderSide(
            color: _darkColorScheme.primary.withValues(alpha: 0.5),
            width: 1.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SamsUiTokens.radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkColorScheme.primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SamsUiTokens.radiusMd),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: _darkNavSurface,
        selectedItemColor: _darkColorScheme.primary,
        unselectedItemColor: _darkColorScheme.onSurfaceVariant,
        selectedIconTheme: const IconThemeData(size: 24),
        unselectedIconTheme: const IconThemeData(size: 22),
        showUnselectedLabels: true,
        elevation: 8,
      ),
      dividerTheme: DividerThemeData(
        color: _darkColorScheme.outlineVariant.withValues(alpha: 0.8),
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: _darkColorScheme.onSurfaceVariant,
        textColor: _darkColorScheme.onSurface,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _darkColorScheme.surfaceContainerHighest,
        contentTextStyle: TextStyle(color: _darkColorScheme.onSurface),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return selected ? Colors.white : _darkColorScheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return selected
              ? primary.withValues(alpha: 0.55)
              : _darkColorScheme.outlineVariant;
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _darkSurfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SamsUiTokens.radiusLg),
          side: BorderSide(
            color: _darkColorScheme.outlineVariant.withValues(alpha: 0.92),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _darkSurfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _darkColorScheme.surfaceContainerHighest,
        selectedColor: primary.withValues(alpha: 0.24),
        disabledColor: _darkColorScheme.outlineVariant,
        side: BorderSide(
          color: _darkColorScheme.outlineVariant.withValues(alpha: 0.9),
        ),
        labelStyle: TextStyle(
          color: _darkColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: TextStyle(
          color: _darkColorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: Color(0xFFE8EDF3),
          fontSize: 22,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          color: Color(0xFFE8EDF3),
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: Color(0xFFE8EDF3),
          fontSize: 15.2,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFFE8EDF3),
          fontSize: 14.2,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFFE8EDF3),
          fontSize: 13.2,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
        bodySmall: TextStyle(
          color: Color(0xFFBDC7D4),
          fontSize: 12.2,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: _darkNavSurface,
        indicatorColor: _darkColorScheme.primary.withValues(alpha: 0.22),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected
                ? _darkColorScheme.primary
                : _darkColorScheme.onSurfaceVariant,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 12,
            color: isSelected
                ? _darkColorScheme.primary
                : _darkColorScheme.onSurfaceVariant,
          );
        }),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
