import 'package:azure_devops/src/services/ads_service.dart';
import 'package:azure_devops/src/services/purchase_service.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:flutter/material.dart';

extension PurpleContext on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  AppColorsExtension get themeExtension => Theme.of(this).extension<AppColorsExtension>()!;
  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;

  PurchaseService get purchaseService => PurchaseServiceWidget.of(this).purchase;
  AdsService get adsService => AdsServiceWidget.of(this).ads;
}
