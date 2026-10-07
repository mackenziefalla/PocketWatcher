import 'package:flutter/material.dart';

class AppColors {
  static const emerald = Color(0xFF16A34A);
  static const navy = Color(0xFF0F172A);
  static const background = Color(0xFFF8FAFC);
  static const cardWhite = Color(0xFFFFFFFF);
  static const softGray = Color(0xFFE5E7EB);
  static const warningRed = Color(0xFFDC2626);
  static const gold = Color(0xFFF59E0B);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.emerald,
      primary: AppColors.emerald,
      secondary: AppColors.navy,
      surface: AppColors.cardWhite,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.navy,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardWhite,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.navy,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.navy,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.navy,
      ),
    ),
  );
}