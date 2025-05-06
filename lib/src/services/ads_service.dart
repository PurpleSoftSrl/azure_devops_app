// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/models/amazon/amazon_item.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/amazon_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const _androidInterstitialAdId = String.fromEnvironment('ADMOB_INTERSTITIAL_ADID_ANDROID');
const _iosInterstitialAdId = String.fromEnvironment('ADMOB_INTERSTITIAL_ADID_IOS');
const _androidNativeAdId = String.fromEnvironment('ADMOB_NATIVE_ADID_ANDROID');
const _iosNativeAdId = String.fromEnvironment('ADMOB_NATIVE_ADID_IOS');

abstract interface class AdsService {
  bool get hasAmazonAds;
  Future<void> init();
  Future<void> showInterstitialAd({VoidCallback? onDismiss});
  void removeAds();
  void reactivateAds();
  Future<List<AdWithView>> getNewNativeAds();
  Future<List<AmazonItem>> getNewAmazonAds();
}

class AdsServiceImpl with AppLogger implements AdsService {
  factory AdsServiceImpl() => _instance ??= AdsServiceImpl._internal();

  AdsServiceImpl._internal();

  static AdsServiceImpl? _instance;

  static const _tag = 'AdsService';

  final _interstitialAdUnitId = Platform.isAndroid ? _androidInterstitialAdId : _iosInterstitialAdId;
  final _nativeAdUnitId = Platform.isAndroid ? _androidNativeAdId : _iosNativeAdId;

  InterstitialAd? _interstitialAd;

  bool _showAds = true;

  @override
  bool get hasAmazonAds => _hasAmazonAds;
  bool _hasAmazonAds = true;

  @override
  Future<void> init() async {
    setTag(_tag);

    await MobileAds.instance.initialize();

    logDebug('initialized');

    await _loadInterstitialAd();
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
          _handleAdFailedToLoad(error, 'interstitial');
        },
      ),
    );
  }

  @override
  Future<void> showInterstitialAd({VoidCallback? onDismiss}) async {
    if (!_showAds) {
      logDebug('Ads are disabled');
      onDismiss?.call();
      return;
    }

    logDebug('showing intertitial ad');

    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdFailedToShowFullScreenContent: (ad, error) {
        logErrorMessage('Interstitial onAdFailedToShowFullScreenContent: $error');
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
  Future<List<AdWithView>> getNewNativeAds() async {
    if (!_showAds) return [];

    final ctx = AppRouter.navigatorKey.currentContext!;

    final newNativeAds = <AdWithView>[];
    final compl = Completer<List<AdWithView>>();

    const adsCount = 1;

    for (var i = 0; i < adsCount; i++) {
      final nativeAd = NativeAd(
        adUnitId: _nativeAdUnitId,
        request: AdRequest(),
        nativeAdOptions: NativeAdOptions(
          mediaAspectRatio: MediaAspectRatio.portrait,
        ),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            logDebug('NativeAd loaded: ${ad.responseInfo?.responseId}.');
            newNativeAds.add(ad as AdWithView);

            if (newNativeAds.length >= adsCount) {
              compl.complete(newNativeAds.where((ad) => ad.adUnitId.isNotEmpty).toList());
            }
          },
          onAdFailedToLoad: (ad, error) {
            newNativeAds.add((ad as NativeAd).copyWith(adUnitId: ''));
            ad.dispose();

            if (newNativeAds.length >= adsCount) {
              compl.complete(newNativeAds.where((ad) => ad.adUnitId.isNotEmpty).toList());
            }

            _debounce(() => _handleAdFailedToLoad(error, 'native'), const Duration(seconds: 2));
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

    return compl.future;
  }

  @override
  Future<List<AmazonItem>> getNewAmazonAds() async {
    if (!_showAds) return [];
    if (!_hasAmazonAds) return [];

    final items = await AmazonService().getItems();
    if (items.isEmpty) {
      logDebug('No Amazon ads found');
      _hasAmazonAds = false;
    } else {
      _hasAmazonAds = true;
    }

    return items;
  }

  void _handleAdFailedToLoad(LoadAdError error, String adType) {
    final errorCode = error.code;
    final errorMessage = error.message;

    final errorLog = '$adType ad failed to load: Code: $errorCode - Message: $errorMessage';

    if (_isNetworkError(errorMessage)) {
      logDebug(errorLog);
      return;
    }

    if (_isJavascriptEngineNotFound(errorMessage)) {
      _stopRequestingAds();
    }

    if (_isTooManyFailedRequests(errorMessage)) {
      _pauseRequestingAds();
    }

    logErrorMessage(errorLog);
  }

  bool _isNetworkError(String errorMessage) => [
        'network error',
        'error while connecting to ad server',
        'the request timed out',
        'timeout occurred',
        'internet connection appears to be offline',
        'network connection was lost',
      ].any(errorMessage.toLowerCase().contains);

  bool _isTooManyFailedRequests(String errorMessage) =>
      errorMessage.toLowerCase().contains('too many recently failed requests');

  bool _isJavascriptEngineNotFound(String errorMessage) =>
      errorMessage.toLowerCase().contains('unable to obtain a javascriptengine');

  /// Stops requesting ads for 30 seconds.
  void _pauseRequestingAds() {
    logDebug('Pausing requesting ads');
    _showAds = false;

    Timer(const Duration(seconds: 30), () {
      _showAds = true;
      logDebug('Ads can be requested again');
    });
  }

  void _stopRequestingAds() {
    logDebug('Stopping requesting ads');
    _showAds = false;
  }
}

extension on NativeAd {
  NativeAd copyWith({required String adUnitId}) {
    return NativeAd(
      adUnitId: adUnitId,
      request: request,
      nativeAdOptions: nativeAdOptions,
      listener: listener,
      nativeTemplateStyle: nativeTemplateStyle,
    );
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

Timer? _debounceTimer;
void _debounce(dynamic Function() action, Duration duration) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(duration, action);
}
