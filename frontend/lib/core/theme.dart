import 'package:flutter/material.dart';

/// Tema terpusat aplikasi SolaCalcSRE.
/// Warna diambil dari logo Sumber Rejeki Energy: hijau/teal untuk primary
/// (bohlam & sunburst), sedikit aksen biru untuk secondary (elemen "SR").
/// Disatukan di sini supaya konsisten dan gampang diubah dari satu tempat
/// kalau nanti perlu disesuaikan lagi dengan brand guideline resmi.
class AppTheme {
  AppTheme._();

  // Warna inti brand
  static const Color primaryTeal = Color(0xFF0E9488);
  static const Color secondaryBlue = Color(0xFF2B4C9B);
  static const Color accentGreen = Color(0xFF3FAE5A);

  // Warna khusus perbandingan baterai, dipakai di PerbandinganBateraiCard
  static const Color warnaVrla = primaryTeal;
  static const Color warnaLifepo4 = secondaryBlue;

  static const double radiusDefault = 12;
  static const double radiusKecil = 8;

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF3F8F7),

      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF3F8F7),
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusKecil),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusKecil),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusKecil),
          ),
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: primaryTeal,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: primaryTeal,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
      ),

      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDefault),
        ),
      ),
    );
  }
}