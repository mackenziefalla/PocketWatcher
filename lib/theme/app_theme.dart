import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Brand colors used across both themes.
class AppColors {
  static const emerald = Color(0xFF16A34A);
  static const mint = Color(0xFF22C55E);
  static const navy = Color(0xFF0F172A);
  static const background = Color(0xFFF6F7F9);
  static const cardWhite = Color(0xFFFFFFFF);
  static const softGray = Color(0xFFE5E7EB);
  static const warningRed = Color(0xFFDC2626);
  static const gold = Color(0xFFF59E0B);

  // Dark mode surfaces
  static const darkBackground = Color(0xFF0B1220);
  static const darkCard = Color(0xFF131C2E);
  static const darkCardHigh = Color(0xFF1C2740);
  static const darkText = Color(0xFFE6EAF2);
  static const darkMuted = Color(0xFF94A3B8);
}

/// Remembers whether the user picked light, dark, or system theme.
class ThemeController {
  static const String _key = 'theme_mode';

  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    mode.value = ThemeMode.values.firstWhere(
      (value) => value.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  /// Switches between light and dark based on what is showing now.
  static Future<void> toggle(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    mode.value = isDark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.value.name);
  }
}

class AppTheme {
  static ThemeData lightTheme = _build(Brightness.light);
  static ThemeData darkTheme = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final background = isDark ? AppColors.darkBackground : AppColors.background;
    final card = isDark ? AppColors.darkCard : AppColors.cardWhite;
    final text = isDark ? AppColors.darkText : AppColors.navy;
    final muted = isDark ? AppColors.darkMuted : const Color(0xFF64748B);
    final primary = isDark ? AppColors.mint : AppColors.emerald;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.emerald,
      brightness: brightness,
    ).copyWith(
      primary: primary,
      onPrimary: isDark ? AppColors.darkBackground : Colors.white,
      secondary: isDark ? AppColors.darkText : AppColors.navy,
      surface: card,
      onSurface: text,
      onSurfaceVariant: muted,
      surfaceContainerHighest:
          isDark ? AppColors.darkCardHigh : const Color(0xFFF1F5F9),
      outlineVariant:
          isDark ? const Color(0xFF243049) : const Color(0xFFE2E8F0),
      error: AppColors.warningRed,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: text,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primary,
        textColor: text,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary.withValues(alpha: 0.16),
        height: 68,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: text),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary.withValues(alpha: isDark ? 0.18 : 0.10),
          foregroundColor: primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: text,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: text,
          letterSpacing: -0.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: text,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: text,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: text,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: text),
        bodyMedium: TextStyle(fontSize: 14, color: text),
        bodySmall: TextStyle(fontSize: 12, color: muted),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}