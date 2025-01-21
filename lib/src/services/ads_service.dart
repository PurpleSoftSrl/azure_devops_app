// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const _androidInterstitialAdId = String.fromEnvironment('ADMOB_INTERSTITIAL_ADID_ANDROID');
const _iosInterstitialAdId = String.fromEnvironment('ADMOB_INTERSTITIAL_ADID_IOS');
const _androidNativeAdId = String.fromEnvironment('ADMOB_NATIVE_ADID_ANDROID');
const _iosNativeAdId = String.fromEnvironment('ADMOB_NATIVE_ADID_IOS');

abstract interface class AdsService {
  ValueNotifier<List<AdWithView>> get nativeAds;
  Future<void> init();
  Future<void> showInterstitialAd({VoidCallback? onDismiss});
  void removeAds();
  void reactivateAds();
  void refreshNativeAds();
}

class AdsServiceImpl with AppLogger implements AdsService {
  factory AdsServiceImpl() => _instance ??= AdsServiceImpl._internal();

  AdsServiceImpl._internal();

  static AdsServiceImpl? _instance;

  static const _tag = 'AdsService';

  final _interstitialAdUnitId = Platform.isAndroid ? _androidInterstitialAdId : _iosInterstitialAdId;
  final _nativeAdUnitId = Platform.isAndroid ? _androidNativeAdId : _iosNativeAdId;

  InterstitialAd? _interstitialAd;

  @override
  ValueNotifier<List<AdWithView>> nativeAds = ValueNotifier([]);

  bool _showAds = true;

  @override
  Future<void> init() async {
    setTag(_tag);

    await MobileAds.instance.initialize();

    logDebug('initialized');

    await _loadInterstitialAd();
    await _loadNativeAds();
  }

  /// Loads an interstitial ad.
  Future<void> _loadInterstitialAd() async {
    logDebug('Loading interstitial ad: $_interstitialAdUnitId');

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
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

  Future<void> _loadNativeAds() async {
    final ctx = AppRouter.navigatorKey.currentContext!;

    for (var i = 0; i < 3; i++) {
      final nativeAd = NativeAd(
        adUnitId: _nativeAdUnitId,
        request: AdRequest(),
        nativeAdOptions: NativeAdOptions(
          mediaAspectRatio: MediaAspectRatio.portrait,
        ),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            logDebug('NativeAd loaded.');
            nativeAds.value = [...nativeAds.value, ad as AdWithView];
          },
          onAdFailedToLoad: (ad, error) {
            logError('NativeAd failed to load: $error', error);
            ad.dispose();
          },
          onAdImpression: (ad) => logDebug('NativeAd onAdImpression.'),
        ),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.small,
          mainBackgroundColor: ctx.themeExtension.background,
          callToActionTextStyle: NativeTemplateTextStyle(size: 16),
          primaryTextStyle: NativeTemplateTextStyle(
            textColor: ctx.themeExtension.onBackground,
          ),
        ),
      );

      await nativeAd.load();
    }
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

  @override
  void refreshNativeAds() {
    for (final ad in nativeAds.value) {
      ad.dispose();
    }
    nativeAds.value = [];
    _loadNativeAds();
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
