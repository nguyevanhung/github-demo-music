import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Colors.deepPurple;
  static const Color accent = Colors.deepPurpleAccent;
  static const Color background = Color(0xFFF5F5F5);
  static const Color text = Colors.black87;
  static const Color white = Colors.white;
  static const Color error = Colors.redAccent;
  // Thêm các màu khác nếu cần
}

final ThemeData appLightTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    centerTitle: true,
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    background: AppColors.background,
    error: AppColors.error,
  ),
);

final ThemeData appDarkTheme = ThemeData.dark().copyWith(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    centerTitle: true,
  ),
  colorScheme: ColorScheme.dark().copyWith(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    background: Colors.black,
    error: AppColors.error,
  ),
);
