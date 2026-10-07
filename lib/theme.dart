import 'package:flutter/material.dart';

class AppColors {
  static const indigo = Color(0xFF2E2A9E);
  static const violet = Color(0xFF6C4CF1);
  static const saffron = Color(0xFFFF8A00);
  static const green = Color(0xFF16A34A);
  static const red = Color(0xFFDC2626);
  static const amber = Color(0xFFF59E0B);
  static const sky = Color(0xFF0EA5E9);
  static const pink = Color(0xFFEC4899);
  static const teal = Color(0xFF14B8A6);
  static const slate = Color(0xFF64748B);

  static const brand = LinearGradient(
    colors: [Color(0xFF2E2A9E), Color(0xFF6C4CF1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color subject(String s) {
    final k = s.toLowerCase();
    if (k.contains('math')) return const Color(0xFF2563EB);
    if (k.contains('english')) return const Color(0xFF16A34A);
    if (k.contains('science') || k.contains('evs')) return const Color(0xFF0D9488);
    if (k.contains('social')) return const Color(0xFFB45309);
    if (k.contains('telugu')) return const Color(0xFFDB2777);
    if (k.contains('hindi')) return const Color(0xFFEA580C);
    if (k.contains('computer')) return const Color(0xFF7C3AED);
    if (k.contains('chess')) return const Color(0xFF475569);
    if (k.contains('art')) return const Color(0xFFE11D48);
    if (k.contains('pe') || k.contains('sport') || k.contains('swim')) return const Color(0xFF0284C7);
    return const Color(0xFF6366F1);
  }
}

class AppTheme {
  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness b) {
    final light = b == Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.violet,
      brightness: b,
      secondary: AppColors.saffron,
    );
    final radius = BorderRadius.circular(14);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: light ? const Color(0xFFF4F5FB) : const Color(0xFF0E0F1A),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: light ? const Color(0xFFF4F5FB) : const Color(0xFF0E0F1A),
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: light ? Colors.white : const Color(0xFF1A1B2B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: light ? const Color(0xFFE6E8F2) : const Color(0xFF2A2C40)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: light ? Colors.white : const Color(0xFF1A1B2B),
        border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: scheme.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: scheme.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: scheme.primary, width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 46),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      chipTheme: ChipThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      navigationBarTheme: NavigationBarThemeData(
        height: 66,
        backgroundColor: light ? Colors.white : const Color(0xFF15162A),
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: scheme.onSurface),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
