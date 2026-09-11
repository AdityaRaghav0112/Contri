import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF005048);
  static const Color primaryContainer = Color(0xFF006A60);

  static const Color surface = Color(0xFFF2FBF9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEDF6F3);
  static const Color surfaceContainer = Color(0xFFE7F0ED);
  static const Color surfaceContainerHigh = Color(0xFFE1EAE7);
  static const Color surfaceContainerHighest = Color(0xFFDBE4E2);

  static const Color onSurface = Color(0xFF151D1C);
  static const Color onSurfaceVariant = Color(0xFF3E4947);

  static const Color secondary = Color(0xFF4A635F);
  static const Color secondaryContainer = Color(0xFFCAE5E0);

  static const Color error = Color(0xFFBA1A1A);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      primaryContainer: primaryContainer,
      surface: surface,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      secondary: secondary,
      secondaryContainer: secondaryContainer,
      error: error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,

      fontFamily: 'Roboto',

      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      cardTheme: const CardThemeData(
        elevation: 0,
        color: surfaceContainerLowest,
        margin: EdgeInsets.zero,
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: surfaceContainer,
        elevation: 0,
        indicatorColor: secondaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: onSurface,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
    );
  }
}