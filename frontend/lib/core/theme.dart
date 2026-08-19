import 'package:flutter/material.dart';

/// Tema terpusat aplikasi SolaCalcSRE.
/// Monokrom hijau tosca — semua warna berasal dari satu seed (#0D9488)
/// dengan variasi shade untuk kebutuhan visual yang berbeda.
class AppTheme {
  AppTheme._();

  // ── Warna inti brand ──────────────────────────────────────────────
  static const Color primaryTosca = Color(0xFF0D9488);
  static const Color toscaLight = Color(0xFF14B8A6);
  static const Color toscaDark = Color(0xFF0F766E);

  // ── Warna khusus kartu perbandingan baterai ───────────────────────
  static const Color warnaVrla = toscaDark;
  static const Color warnaLifepo4 = toscaLight;

  // ── Radius ────────────────────────────────────────────────────────
  static const double radiusDefault = 12;
  static const double radiusKecil = 8;

  // ── Font family ───────────────────────────────────────────────────
  static const String _fontFamily = 'PlusJakartaSans';

  // ── ThemeData ─────────────────────────────────────────────────────
  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryTosca,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFB2DFDB),
      onPrimaryContainer: toscaDark,
      secondary: toscaLight,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFB2DFDB),
      onSecondaryContainer: toscaDark,
      tertiary: toscaDark,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFB2DFDB),
      onTertiaryContainer: toscaDark,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surface: Colors.white,
      onSurface: Color(0xFF1C1B1F),
      onSurfaceVariant: Color(0xFF49454F),
      outline: Color(0xFF79747E),
      outlineVariant: Color(0xFFCAC4D0),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      surfaceTint: Colors.transparent,
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: toscaLight,
      surfaceDim: Color(0xFFDDD8DA),
      surfaceBright: Color(0xFFFDF8FA),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFF7F2F4),
      surfaceContainer: Color(0xFFF1ECED),
      surfaceContainerHigh: Color(0xFFECE7E8),
      surfaceContainerHighest: Color(0xFFE6E1E3),
    );

    const textTheme = TextTheme(
      displayLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700),
      displayMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700),
      displaySmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600),
      headlineLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w500),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: Color(0xFFF5F5F5),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
        ),
        margin: EdgeInsets.zero,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusKecil),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusKecil),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusKecil),
          borderSide: BorderSide(color: primaryTosca, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryTosca,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusKecil),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTosca,
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: primaryTosca),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusKecil),
          ),
        ),
      ),

      tabBarTheme: const TabBarThemeData(
        labelColor: primaryTosca,
        unselectedLabelColor: Color(0xFF94A3B8),
        indicatorColor: primaryTosca,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w400, fontSize: 13),
      ),

      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: toscaDark,
        contentTextStyle: const TextStyle(fontFamily: _fontFamily, color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusKecil)),
      ),
    );
  }
}
