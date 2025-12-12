import 'dart:ui';

import 'package:azure_devops/src/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _lightColorScheme = ColorScheme(
  primary: Color.fromRGBO(51, 118, 205, 1),
  primaryContainer: Color(0xFF74759A),
  onPrimary: Color(0xFFFFFFFF),
  onSecondary: Color(0xFFA6A6A6),
  secondary: Color.fromRGBO(65, 95, 141, 1),
  secondaryContainer: Color(0x5B3C3C43),
  surface: Color.fromRGBO(255, 255, 255, 1),
  brightness: Brightness.light,
  error: Colors.red,
  onError: Color(0xFFF3F3F4),
  onSurface: Color.fromRGBO(154, 154, 154, 1),
  tertiaryContainer: Color.fromRGBO(220, 220, 220, 1),
);

const _darkColorScheme = ColorScheme(
  primary: Color.fromRGBO(51, 118, 205, 1),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF74759A),
  secondary: Color(0xFFE37322),
  onSecondary: Color(0xFFA6A6A6),
  secondaryContainer: Color(0xA5545458),
  surface: Color.fromRGBO(50, 49, 48, 1),
  onSurface: Color.fromRGBO(244, 244, 244, 1),
  error: Colors.red,
  onError: Color(0xFFF3F3F4),
  brightness: Brightness.dark,
  tertiaryContainer: Color.fromRGBO(73, 73, 73, 1),
);

const _lightBackground = Color.fromRGBO(248, 248, 248, 1);
const _lightOnBackground = Color.fromRGBO(25, 25, 25, 1);
const _darkBackground = Color.fromRGBO(32, 31, 30, 1);
const _darkOnBackground = Color.fromRGBO(214, 214, 214, 1);

class AppTheme {
  static double radius = 8;

  static int tabletBreakpoint = 600;

  static MediaQueryData get _platformMediaQuery => MediaQueryData.fromView(PlatformDispatcher.instance.views.first);

  static bool isTablet = _platformMediaQuery.size.width >= tabletBreakpoint;

  static StorageService get storage => StorageServiceCore();

  static bool get isLightTheme => storage.getThemeMode() == 'light';

  static bool get isDarkTheme => storage.getThemeMode() == 'dark';

  static bool get isSystemTheme => storage.getThemeMode().isEmpty || storage.getThemeMode() == 'system';

  static String get themeMode {
    if (isSystemTheme) return 'System';
    if (isDarkTheme) return 'Dark';
    return 'Light';
  }

  static Brightness get _platformBrightness => _platformMediaQuery.platformBrightness;

  static bool get _isPlatformBrightnessLight => _platformBrightness == Brightness.light;

  /// Returns theme saved in local storage if any, otherwise defaults to dark theme.
  static ThemeData get darkTheme {
    if (isSystemTheme) {
      return _getCustomTheme(_isPlatformBrightnessLight ? _lightColorScheme : _darkColorScheme);
    }
    return _getCustomTheme(isLightTheme ? _lightColorScheme : _darkColorScheme);
  }

  static ThemeData get lightTheme {
    if (isSystemTheme) {
      return _getCustomTheme(_isPlatformBrightnessLight ? _lightColorScheme : _darkColorScheme);
    }
    return _getCustomTheme(isDarkTheme ? _darkColorScheme : _lightColorScheme);
  }

  static Map<String, ThemeData> get allThemes => {
    'light': _getCustomTheme(_lightColorScheme),
    'dark': _getCustomTheme(_darkColorScheme),
  };

  static final defaultFont = GoogleFonts.notoSans().fontFamily;

  static ThemeData _getCustomTheme(ColorScheme colorScheme) {
    final textTheme = _getTextTheme(colorScheme.brightness);

    final themeExtension = _getThemeExtension();

    return ThemeData(
      useMaterial3: true,
      extensions: [themeExtension],
      fontFamily: defaultFont,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      scaffoldBackgroundColor: themeExtension.background,
      buttonTheme: _getButtonTheme(colorScheme),
      textButtonTheme: _getTextButtonTheme(textTheme, themeExtension),
      dividerTheme: _getDividerTheme(colorScheme),
      iconTheme: _getIconTheme(themeExtension),
      snackBarTheme: _getSnackbarTheme(colorScheme, textTheme),
      shadowColor: Colors.transparent,
      appBarTheme: _getAppBarTheme(colorScheme, textTheme, themeExtension),
      chipTheme: _getChipTheme(textTheme, colorScheme, themeExtension),
      dialogTheme: _getDialogTheme(colorScheme),
      bottomSheetTheme: _getBottomSheetTheme(colorScheme),
      checkboxTheme: _getCheckboxTheme(colorScheme, themeExtension),
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
      color: brightness == Brightness.light ? _lightOnBackground : _darkOnBackground,
      decorationColor: brightness == Brightness.light ? _lightOnBackground : _darkOnBackground,
      fontWeight: fontWeight,
      fontSize: fsMultiplier * fs,
      height: height == null ? null : height / (fsMultiplier * fs),
      letterSpacing: letterSpacing,
    );
  }

  static AppColorsExtension _getThemeExtension() {
    if (isSystemTheme) {
      return AppColorsExtension(
        background: _isPlatformBrightnessLight ? _lightBackground : _darkBackground,
        onBackground: _isPlatformBrightnessLight ? _lightOnBackground : _darkOnBackground,
      );
    }

    return AppColorsExtension(
      background: isLightTheme ? _lightBackground : _darkBackground,
      onBackground: isLightTheme ? _lightOnBackground : _darkOnBackground,
    );
  }

  static CheckboxThemeData _getCheckboxTheme(ColorScheme colorScheme, AppColorsExtension ext) {
    return CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? colorScheme.primary : ext.background;
      }),
      side: BorderSide(width: .5, color: ext.onBackground),
    );
  }

  static BottomSheetThemeData _getBottomSheetTheme(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      backgroundColor: colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(radius), topRight: Radius.circular(radius)),
      ),
      elevation: 10,
      modalElevation: 10,
      modalBackgroundColor: colorScheme.primary,
    );
  }

  static DialogThemeData _getDialogTheme(ColorScheme colorScheme) {
    return DialogThemeData(
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

  static ChipThemeData _getChipTheme(TextTheme textTheme, ColorScheme colorScheme, AppColorsExtension ext) {
    return ChipThemeData(
      padding: EdgeInsets.only(left: 10, right: 10),
      labelPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
      side: BorderSide(color: Colors.transparent),
      labelStyle: textTheme.labelSmall!.copyWith(color: ext.onBackground),
      backgroundColor: colorScheme.tertiaryContainer,
    );
  }

  static AppBarTheme _getAppBarTheme(ColorScheme colorScheme, TextTheme textTheme, AppColorsExtension ext) {
    return AppBarTheme(
      elevation: 0,
      backgroundColor: ext.background,
      titleTextStyle: textTheme.titleLarge!.copyWith(color: ext.onBackground),
      centerTitle: true,
      shadowColor: colorScheme.primary,
      iconTheme: IconThemeData(color: ext.onBackground),
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

  static IconThemeData _getIconTheme(AppColorsExtension ext) {
    return IconThemeData(color: ext.onBackground, size: isTablet ? 30 : 20);
  }

  static DividerThemeData _getDividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(thickness: 1, color: colorScheme.secondaryContainer);
  }

  static TextButtonThemeData _getTextButtonTheme(TextTheme textTheme, AppColorsExtension ext) {
    return TextButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
        foregroundColor: WidgetStatePropertyAll(ext.onBackground),
        padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }

  static ButtonThemeData _getButtonTheme(ColorScheme colorScheme) {
    return ButtonThemeData(
      hoverColor: Colors.transparent,
      buttonColor: colorScheme.primary,
      disabledColor: colorScheme.surface,
      height: isTablet ? 70.0 : 60.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    );
  }
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  AppColorsExtension({required this.background, required this.onBackground});

  final Color background;
  final Color onBackground;

  @override
  ThemeExtension<AppColorsExtension> copyWith() {
    return this;
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }

    return AppColorsExtension(
      background: Color.lerp(background, other.background, t) ?? background,
      onBackground: Color.lerp(onBackground, other.onBackground, t) ?? onBackground,
    );
  }
}
