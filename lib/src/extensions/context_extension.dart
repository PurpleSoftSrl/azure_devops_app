import 'package:flutter/material.dart';

extension PurpleContext on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  double get height => MediaQuery.of(this).size.height;
}
