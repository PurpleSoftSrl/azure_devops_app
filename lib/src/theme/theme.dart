import 'dart:ui';

import 'package:azure_devops/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _lightColorScheme = ColorScheme(
  primary: Color.fromRGBO(51, 118, 205, 1),
  primaryContainer: Color(0xFF74759A),
  background: Color.fromRGBO(248, 248, 248, 1),
  onBackground: Color.fromRGBO(25, 25, 25, 1),
  onPrimary: Color(0xFFFFFFFF),
  onSecondary: Color(0xFFA6A6A6),
  secondary: Color.fromRGBO(65, 95, 141, 1),
  secondaryContainer: Color(0x5B3C3C43),
  surface: Color.fromRGBO(255, 255, 255, 1),
  brightness: Brightness.light,
  error: Colors.red,
  onError: Color(0xFFF3F3F4),
  onSurface: Color.fromRGBO(154, 154, 154, 1),
);

const _darkColorScheme = ColorScheme(
  primary: Color.fromRGBO(51, 118, 205, 1),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF74759A),
  background: Color.fromRGBO(32, 31, 30, 1),
  onBackground: Color.fromRGBO(214, 214, 214, 1),
  secondary: Color(0xFFE37322),
  onSecondary: Color(0xFFA6A6A6),
  secondaryContainer: Color(0xA5545458),
  surface: Color.fromRGBO(50, 49, 48, 1),
  onSurface: Color.fromRGBO(244, 244, 244, 1),
  error: Colors.red,
  onError: Color(0xFFF3F3F4),
  brightness: Brightness.dark,
);

class AppTheme {
  static double radius = 8;

  static int tabletBeakpoint = 600;

  static bool get isLightTheme => StorageServiceCore().getThemeMode() == 'light';

  static bool get isDarkTheme => StorageServiceCore().getThemeMode() == 'dark';

  static bool get isSystemTheme =>
      StorageServiceCore().getThemeMode().isEmpty || StorageServiceCore().getThemeMode() == 'system';

  static String get themeMode {
    if (isSystemTheme) return 'System';
    if (isDarkTheme) return 'Dark';
    return 'Light';
  }

  /// Returns theme saved in local storage if any, otherwise defaults to dark theme.
  static ThemeData get darkTheme {
    return _getCustomTheme(isLightTheme ? _lightColorScheme : _darkColorScheme);
  }

  static ThemeData get lightTheme {
    return _getCustomTheme(isDarkTheme ? _darkColorScheme : _lightColorScheme);
  }

  static Map<String, ThemeData> get allThemes => {
        'light': _getCustomTheme(_lightColorScheme),
        'dark': _getCustomTheme(_darkColorScheme),
      };

  static final defaultFont = GoogleFonts.notoSans().fontFamily;

  // ignore: long-method
  static ThemeData _getCustomTheme(ColorScheme colorScheme) {
    final letterSpacing = .5;

    final isTablet = (MediaQueryData.fromWindow(window).size.width) >= tabletBeakpoint;

    final fsMultiplier = isTablet ? 1.2 : 1.0;

    final textTheme = GoogleFonts.notoSansTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontFamily: defaultFont,
          color: colorScheme.onBackground,
          fontWeight: FontWeight.w700,
          fontSize: 57 * fsMultiplier,
          height: 64 / (57 * fsMultiplier),
          letterSpacing: letterSpacing,
        ),
        displayMedium: TextStyle(
          fontFamily: defaultFont,
          color: colorScheme.onBackground,
          fontSize: 45 * fsMultiplier,
          fontWeight: FontWeight.w500,
          height: 52 / (45 * fsMultiplier),
          letterSpacing: letterSpacing,
        ),
        displaySmall: TextStyle(
          fontFamily: defaultFont,
          color: colorScheme.onBackground,
          fontSize: 36 * fsMultiplier,
          fontWeight: FontWeight.w700,
          height: 44 / (36 * fsMultiplier),
          letterSpacing: letterSpacing,
        ),
        headlineLarge: TextStyle(
          fontFamily: defaultFont,
          color: colorScheme.onBackground,
          fontSize: 32 * fsMultiplier,
          fontWeight: FontWeight.w600,
          height: 40 / (32 * fsMultiplier),
          letterSpacing: letterSpacing,
        ),
        headlineMedium: TextStyle(
          fontFamily: defaultFont,
          color: colorScheme.onBackground,
          fontSize: 28 * fsMultiplier,
          fontWeight: FontWeight.w600,
          height: 36 / (28 * fsMultiplier),
          letterSpacing: letterSpacing,
        ),
        headlineSmall: TextStyle(
          fontFamily: defaultFont,
          color: colorScheme.onBackground,
          fontSize: 24 * fsMultiplier,
          fontWeight: FontWeight.w600,
          letterSpacing: letterSpacing,
        ),
        titleLarge: TextStyle(
          fontFamily: defaultFont,
          color: colorScheme.onBackground,
          fontSize: 20 * fsMultiplier,
          fontWeight: FontWeight.w600,
          letterSpacing: letterSpacing,
        ),
        titleMedium: TextStyle(
          fontFamily: defaultFont,
          color: colorScheme.onBackground,
          fontWeight: FontWeight.w600,
          fontSize: 16 * fsMultiplier,
          letterSpacing: letterSpacing,
        ),
        titleSmall: TextStyle(
          fontFamily: defaultFont,
          color: colorScheme.onBackground,
          fontSize: 14 * fsMultiplier,
          fontWeight: FontWeight.w500,
          height: 20 / (14 * fsMultiplier),
          letterSpacing: letterSpacing,
        ),
        bodyLarge: TextStyle(
          fontFamily: defaultFont,
          color: colorScheme.onBackground,
          fontSize: 16 * fsMultiplier,
          height: 24 / (16 * fsMultiplier),
          fontWeight: FontWeight.w500,
          letterSpacing: letterSpacing,
        ),
        bodyMedium: TextStyle(
          fontFamily: defaultFont,
          color: colorScheme.onBackground,
          fontSize: 14 * fsMultiplier,
          height: 20 / (14 * fsMultiplier),
          fontWeight: FontWeight.w700,
          letterSpacing: letterSpacing,
        ),
        bodySmall: TextStyle(
          fontFamily: defaultFont,
          color: colorScheme.onBackground,
          fontSize: 12 * fsMultiplier,
          fontWeight: FontWeight.w400,
          height: 16 / (12 * fsMultiplier),
          letterSpacing: letterSpacing,
        ),
        labelLarge: TextStyle(
          fontFamily: defaultFont,
          color: colorScheme.onBackground,
          fontSize: 14 * fsMultiplier,
          fontWeight: FontWeight.w500,
          height: 20 / (14 * fsMultiplier),
          letterSpacing: letterSpacing,
        ),
        labelMedium: TextStyle(
          fontFamily: defaultFont,
          color: colorScheme.onBackground,
          fontSize: 12 * fsMultiplier,
          fontWeight: FontWeight.w600,
          height: 16 / (12 * fsMultiplier),
          letterSpacing: letterSpacing,
        ),
        labelSmall: TextStyle(
          fontFamily: defaultFont,
          color: colorScheme.onBackground,
          fontSize: 11 * fsMultiplier,
          fontWeight: FontWeight.w500,
          letterSpacing: letterSpacing,
          height: 16 / (11 * fsMultiplier),
        ),
      ),
    );

    return ThemeData(
      fontFamily: defaultFont,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      scaffoldBackgroundColor: colorScheme.background,
      buttonTheme: ButtonThemeData(
        hoverColor: Colors.transparent,
        buttonColor: colorScheme.primary,
        disabledColor: colorScheme.surface,
        height: isTablet ? 70.0 : 60.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: MaterialStatePropertyAll(textTheme.labelLarge),
          foregroundColor: MaterialStatePropertyAll(colorScheme.onBackground),
          padding: MaterialStatePropertyAll(EdgeInsets.all(10)),
          shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 1,
        color: colorScheme.secondaryContainer,
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onBackground,
        size: isTablet ? 30 : 20,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surface,
        contentTextStyle: textTheme.titleSmall,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      shadowColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        elevation: 0,
        color: colorScheme.background,
        titleTextStyle: textTheme.titleLarge!.copyWith(color: colorScheme.onBackground),
        centerTitle: true,
        shadowColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
      ),
      chipTheme: ChipThemeData(
        labelStyle: textTheme.labelSmall!.copyWith(color: colorScheme.onBackground),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.surface,
        shape: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        shadowColor: Colors.transparent,
        titleTextStyle: TextStyle(fontSize: isTablet ? 24 : 20),
        contentTextStyle: TextStyle(
          fontFamily: defaultFont,
          fontWeight: FontWeight.bold,
          fontSize: isTablet ? 22 : 18,
          color: colorScheme.primary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius),
          ),
        ),
        elevation: 10,
        modalElevation: 10,
        modalBackgroundColor: colorScheme.primary,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        fillColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.selected) ? colorScheme.primary : colorScheme.onBackground;
        }),
        side: BorderSide(
          width: .5,
          color: colorScheme.onBackground,
        ),
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
    );
  }
}
