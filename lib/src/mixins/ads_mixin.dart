import 'package:azure_devops/src/services/ads_service.dart';
import 'package:azure_devops/src/widgets/ad_widget.dart';
import 'package:flutter/widgets.dart';

mixin AdsMixin {
  List<AdWithKey> ads = [];

  /// Load new native ads and map them to [AdWithKey] objects with a new global key to force refresh the UI.
  Future<void> getNewNativeAds(AdsService adsService) async {
    final ads2 = await adsService.getNewNativeAds();
    ads = ads2.map((ad) => (ad: ad, key: GlobalKey())).toList();
  }
}
