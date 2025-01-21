import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdWidget extends StatelessWidget {
  const NativeAdWidget({required this.adsIndex});

  final int adsIndex;

  @override
  Widget build(BuildContext context) {
    final nativeAds = context.adsService.nativeAds;
    return ValueListenableBuilder(
      valueListenable: nativeAds,
      builder: (_, ads, __) => adsIndex < ads.length
          ? SizedBox(
              height: 160,
              child: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: AdWidget(
                  ad: ads[adsIndex],
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}
