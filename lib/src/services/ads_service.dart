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

  static const _tag = 'AdsService';

  final adUnitId = Platform.isAndroid ? _androidInterstitialAdId : _iosInterstitialAdId;

  InterstitialAd? _interstitialAd;

  bool _showAds = true;

  Future<void> init() async {
    setTag(_tag);

    await MobileAds.instance.initialize();

    logDebug('initialized');

    await _loadInterstitialAd();
  }

  /// Loads an interstitial ad.
  Future<void> _loadInterstitialAd() async {
    logDebug('loading interstitial ad: $adUnitId');

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          logDebug('Loaded ad: ${ad.toPrintableString()}');
        },
        onAdFailedToLoad: (error) {
          logError('InterstitialAd failed to load: $error', error);
        },
      ),
    );
  }

  Future<void> showInterstitialAd({VoidCallback? onDismiss}) async {
    if (!_showAds) {
      logDebug('Ads are disabled');
      return;
    }

    logDebug('showing intertitial ad');

    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdFailedToShowFullScreenContent: (ad, error) {
        logError('onAdFailedToShowFullScreenContent: ${ad.adUnitId}', error);
        ad.dispose();
        _loadInterstitialAd();
        onDismiss?.call();
      },
      onAdImpression: (ad) {
        logDebug('onAdImpression: ${ad.adUnitId}');
      },
      onAdDismissedFullScreenContent: (ad) {
        logDebug('onAdDismissedFullScreenContent: ${ad.adUnitId}');
        ad.dispose();
        _loadInterstitialAd();
        onDismiss?.call();
      },
    );

    try {
      await _interstitialAd?.show();
    } catch (e) {
      logError('Failed to show interstitial ad', e);
    }
  }

  void removeAds() {
    logDebug('Ads removed');
    _showAds = false;
  }

  void reactivateAds() {
    logDebug('Ads reactivated');
    _showAds = true;
  }
}

extension on InterstitialAd {
  String toPrintableString() {
    return 'InterstitialAd {adUnitId: $adUnitId, request: $request, responseInfo: $responseInfo}';
  }
}
