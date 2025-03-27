import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData defaultTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.backGroundColor,
    fontFamily: 'Almarai',
    textTheme: const TextTheme(
      bodySmall: TextStyle(fontSize: 12),
      bodyLarge: TextStyle(fontSize: 12),
      bodyMedium: TextStyle(fontSize: 12),
      displayLarge: TextStyle(fontSize: 12),
      displayMedium: TextStyle(fontSize: 12),
      displaySmall: TextStyle(fontSize: 12),
      headlineLarge: TextStyle(fontSize: 12),
      headlineMedium: TextStyle(fontSize: 12),
      headlineSmall: TextStyle(fontSize: 12),
      labelLarge: TextStyle(fontSize: 12),
      labelMedium: TextStyle(fontSize: 12),
      labelSmall: TextStyle(fontSize: 12),
      titleLarge: TextStyle(fontSize: 12),
      titleMedium: TextStyle(fontSize: 12),
      titleSmall: TextStyle(fontSize: 12),
      // يمكنك تعديل أو إضافة المزيد من الأنماط حسب الحاجة
    ),
    appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backGroundColor,
        foregroundColor: Colors.black,
        surfaceTintColor: AppColors.backGroundColor,
        elevation: 0),
    elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(AppColors.whiteColor),
      backgroundColor: WidgetStatePropertyAll(AppColors.blueColor),
      elevation: WidgetStatePropertyAll(5),
    )),
    colorScheme: ColorScheme.fromSeed(primary: Colors.black, seedColor: Colors.black, surface: Colors.white),
    useMaterial3: true,
  );
}