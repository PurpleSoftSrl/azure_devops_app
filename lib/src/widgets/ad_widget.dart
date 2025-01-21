import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

typedef AdWithKey = ({AdWithView ad, GlobalKey key});

class NativeAdWidget extends StatelessWidget {
  const NativeAdWidget({required this.ad});

  final AdWithKey ad;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Padding(
        padding: const EdgeInsets.only(top: 32),
        child: AdWidget(
          key: ad.key,
          ad: ad.ad,
        ),
      ),
    );
  }
}
