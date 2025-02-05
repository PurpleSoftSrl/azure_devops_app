import 'dart:io';

import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const _androidInterstitialAdId = String.fromEnvironment('ADMOB_INTERSTITIAL_ADID_ANDROID');
const _iosInterstitialAdId = String.fromEnvironment('ADMOB_INTERSTITIAL_ADID_IOS');

abstract interface class AdsService {
  Future<void> init();
  Future<void> showInterstitialAd({VoidCallback? onDismiss});
  void removeAds();
  void reactivateAds();
}

class AdsServiceImpl with AppLogger implements AdsService {
  factory AdsServiceImpl() => _instance ??= AdsServiceImpl._internal();

  AdsServiceImpl._internal();

  static AdsServiceImpl? _instance;

  static const _tag = 'AdsService';

  final _adUnitId = Platform.isAndroid ? _androidInterstitialAdId : _iosInterstitialAdId;

  InterstitialAd? _interstitialAd;

  bool _showAds = true;

  @override
  Future<void> init() async {
    setTag(_tag);

    await MobileAds.instance.initialize();

    logDebug('initialized');

    await _loadInterstitialAd();
  }

  /// Loads an interstitial ad.
  Future<void> _loadInterstitialAd() async {
    logDebug('Loading interstitial ad: $_adUnitId');

    await InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          logDebug('Loaded interstitial ad');
        },
        onAdFailedToLoad: (error) {
          logError('InterstitialAd failed to load: $error', error);
        },
      ),
    );
  }

  @override
  Future<void> showInterstitialAd({VoidCallback? onDismiss}) async {
    if (!_showAds) {
      logDebug('Ads are disabled');
      return;
    }

    logDebug('showing intertitial ad');

    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdFailedToShowFullScreenContent: (ad, error) {
        logError('Interstitial onAdFailedToShowFullScreenContent: $error', error);
        ad.dispose();
        _loadInterstitialAd();
        onDismiss?.call();
      },
      onAdImpression: (ad) {
        logDebug('Interstitial onAdImpression');
      },
      onAdDismissedFullScreenContent: (ad) {
        logDebug('Interstitial onAdDismissedFullScreenContent');
        ad.dispose();
        _loadInterstitialAd();
        onDismiss?.call();
      },
    );

    try {
      await _interstitialAd?.show();
    } catch (e, s) {
      logError('Failed to show interstitial ad: $e', s);
    }
  }

  @override
  void removeAds() {
    logDebug('Ads removed');
    _showAds = false;
  }

  @override
  void reactivateAds() {
    logDebug('Ads reactivated');
    _showAds = true;
  }
}

class AdsServiceWidget extends InheritedWidget {
  const AdsServiceWidget({
    super.key,
    required super.child,
    required this.ads,
  });

  final AdsService ads;

  static AdsServiceWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AdsServiceWidget>()!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
