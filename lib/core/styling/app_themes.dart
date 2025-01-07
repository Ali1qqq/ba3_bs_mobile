import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData defaultTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.backGroundColor,
    fontFamily: 'Almarai',
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
