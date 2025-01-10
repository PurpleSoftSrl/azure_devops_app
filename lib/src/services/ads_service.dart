import 'dart:io';

import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const _androidInterstitialAdId = String.fromEnvironment('ADMOB_INTERSTITIAL_ADID_ANDROID');
const _iosInterstitialAdId = String.fromEnvironment('ADMOB_INTERSTITIAL_ADID_IOS');

class AdsService with AppLogger {
  factory AdsService() => _instance;

  AdsService._internal();

  static final AdsService _instance = AdsService._internal();

  final adUnitId = Platform.isAndroid ? _androidInterstitialAdId : _iosInterstitialAdId;

  InterstitialAd? _interstitialAd;

  Future<void> init() async {
    await MobileAds.instance.initialize();

    logDebug('[AdsService] initialized');

    await _loadInterstitialAd();
  }

  /// Loads an interstitial ad.
  Future<void> _loadInterstitialAd() async {
    logDebug('[AdsService] loading interstitial ad: $adUnitId');

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          logDebug('[AdsService] Loaded ad: ${ad.toPrintableString()}');
        },
        onAdFailedToLoad: (error) {
          logError('[AdsService] InterstitialAd failed to load: $error', error);
        },
      ),
    );
  }

  Future<void> showInterstitialAd({VoidCallback? onDismiss}) async {
    logDebug('[AdsService] showing intertitial ad');

    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdFailedToShowFullScreenContent: (ad, error) {
        logError('[AdsService] onAdFailedToShowFullScreenContent: ${ad.adUnitId}', error);
        ad.dispose();
        _loadInterstitialAd();
        onDismiss?.call();
      },
      onAdImpression: (ad) {
        logDebug('[AdsService] onAdImpression: ${ad.adUnitId}');
      },
      onAdDismissedFullScreenContent: (ad) {
        logDebug('[AdsService] onAdDismissedFullScreenContent: ${ad.adUnitId}');
        ad.dispose();
        _loadInterstitialAd();
        onDismiss?.call();
      },
    );

    try {
      await _interstitialAd?.show();
    } catch (e) {
      logError('[AdsService] Failed to show interstitial ad', e);
    }
  }
}

extension on InterstitialAd {
  String toPrintableString() {
    return 'InterstitialAd {adUnitId: $adUnitId, request: $request, responseInfo: $responseInfo}';
  }
}
