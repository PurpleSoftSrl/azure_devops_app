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

  static bool isTablet =
      (MediaQueryData.fromView(PlatformDispatcher.instance.views.first).size.width) >= tabletBeakpoint;

  static StorageService get storageService => StorageServiceCore();

  static bool get isLightTheme => storageService.getThemeMode() == 'light';

  static bool get isDarkTheme => storageService.getThemeMode() == 'dark';

  static bool get isSystemTheme => storageService.getThemeMode().isEmpty || storageService.getThemeMode() == 'system';

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

  static ThemeData _getCustomTheme(ColorScheme colorScheme) {
    final textTheme = _getTextTheme(colorScheme.brightness);

    return ThemeData(
      fontFamily: defaultFont,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      scaffoldBackgroundColor: colorScheme.background,
      buttonTheme: _getButtonTheme(colorScheme),
      textButtonTheme: _getTextButtonTheme(textTheme, colorScheme),
      dividerTheme: _getDividerTheme(colorScheme),
      iconTheme: _getIconTheme(colorScheme),
      snackBarTheme: _getSnackbarTheme(colorScheme, textTheme),
      shadowColor: Colors.transparent,
      appBarTheme: _getAppBarTheme(colorScheme, textTheme),
      chipTheme: _getChipTheme(textTheme, colorScheme),
      dialogTheme: _getDialogTheme(colorScheme),
      bottomSheetTheme: _getBottomSheetTheme(colorScheme),
      checkboxTheme: _getCheckboxTheme(colorScheme),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
    );
  }

  static TextTheme _getTextTheme(Brightness brightness) {
    return GoogleFonts.notoSansTextTheme(
      TextTheme(
        displayLarge: _getTextStyle(fontWeight: FontWeight.w700, fs: 57, height: 64, brightness: brightness),
        displayMedium: _getTextStyle(fs: 45, fontWeight: FontWeight.w500, height: 52, brightness: brightness),
        displaySmall: _getTextStyle(fs: 36, fontWeight: FontWeight.w700, height: 44, brightness: brightness),
        headlineLarge: _getTextStyle(fs: 32, fontWeight: FontWeight.w600, height: 40, brightness: brightness),
        headlineMedium: _getTextStyle(fs: 28, fontWeight: FontWeight.w600, height: 36, brightness: brightness),
        headlineSmall: _getTextStyle(fs: 24, fontWeight: FontWeight.w600, brightness: brightness),
        titleLarge: _getTextStyle(fs: 20, fontWeight: FontWeight.w600, brightness: brightness),
        titleMedium: _getTextStyle(fs: 16, fontWeight: FontWeight.w600, brightness: brightness),
        titleSmall: _getTextStyle(fs: 14, fontWeight: FontWeight.w500, height: 20, brightness: brightness),
        bodyLarge: _getTextStyle(fs: 16, fontWeight: FontWeight.w500, height: 24, brightness: brightness),
        bodyMedium: _getTextStyle(fs: 14, fontWeight: FontWeight.w700, height: 20, brightness: brightness),
        bodySmall: _getTextStyle(fs: 12, fontWeight: FontWeight.w400, height: 16, brightness: brightness),
        labelLarge: _getTextStyle(fs: 14, fontWeight: FontWeight.w500, height: 20, brightness: brightness),
        labelMedium: _getTextStyle(fs: 12, fontWeight: FontWeight.w600, height: 16, brightness: brightness),
        labelSmall: _getTextStyle(fs: 11, fontWeight: FontWeight.w500, height: 16, brightness: brightness),
      ),
    );
  }

  static TextStyle _getTextStyle({
    required double fs,
    double? height,
    required FontWeight fontWeight,
    required Brightness brightness,
  }) {
    const letterSpacing = .5;
    final fsMultiplier = isTablet ? 1.2 : 1.0;
    return TextStyle(
      fontFamily: defaultFont,
      color: brightness == Brightness.light ? _lightColorScheme.onBackground : _darkColorScheme.onBackground,
      fontWeight: fontWeight,
      fontSize: fsMultiplier * fs,
      height: height == null ? null : height / (fsMultiplier * fs),
      letterSpacing: letterSpacing,
    );
  }

  static CheckboxThemeData _getCheckboxTheme(ColorScheme colorScheme) {
    return CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      fillColor: MaterialStateProperty.resolveWith((states) {
        return states.contains(MaterialState.selected) ? colorScheme.primary : colorScheme.onBackground;
      }),
      side: BorderSide(
        width: .5,
        color: colorScheme.onBackground,
      ),
    );
  }

  static BottomSheetThemeData _getBottomSheetTheme(ColorScheme colorScheme) {
    return BottomSheetThemeData(
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
    );
  }

  static DialogTheme _getDialogTheme(ColorScheme colorScheme) {
    return DialogTheme(
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
    );
  }

  static ChipThemeData _getChipTheme(TextTheme textTheme, ColorScheme colorScheme) {
    return ChipThemeData(
      labelStyle: textTheme.labelSmall!.copyWith(color: colorScheme.onBackground),
    );
  }

  static AppBarTheme _getAppBarTheme(ColorScheme colorScheme, TextTheme textTheme) {
    return AppBarTheme(
      elevation: 0,
      color: colorScheme.background,
      titleTextStyle: textTheme.titleLarge!.copyWith(color: colorScheme.onBackground),
      centerTitle: true,
      shadowColor: colorScheme.primary,
      iconTheme: IconThemeData(color: colorScheme.onBackground),
    );
  }

  static SnackBarThemeData _getSnackbarTheme(ColorScheme colorScheme, TextTheme textTheme) {
    return SnackBarThemeData(
      backgroundColor: colorScheme.surface,
      contentTextStyle: textTheme.titleSmall,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 0,
    );
  }

  static IconThemeData _getIconTheme(ColorScheme colorScheme) {
    return IconThemeData(
      color: colorScheme.onBackground,
      size: isTablet ? 30 : 20,
    );
  }

  static DividerThemeData _getDividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      thickness: 1,
      color: colorScheme.secondaryContainer,
    );
  }

  static TextButtonThemeData _getTextButtonTheme(TextTheme textTheme, ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStatePropertyAll(textTheme.labelLarge),
        foregroundColor: MaterialStatePropertyAll(colorScheme.onBackground),
        padding: MaterialStatePropertyAll(EdgeInsets.all(10)),
        shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }

  static ButtonThemeData _getButtonTheme(ColorScheme colorScheme) {
    return ButtonThemeData(
      hoverColor: Colors.transparent,
      buttonColor: colorScheme.primary,
      disabledColor: colorScheme.surface,
      height: isTablet ? 70.0 : 60.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
