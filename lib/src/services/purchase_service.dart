import 'dart:async';
import 'dart:io';

import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/services/ads_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

const _revenueCatApiKeyIos = String.fromEnvironment('REVENUE_CAT_API_KEY_IOS');
const _revenueCatApiKeyAndroid = String.fromEnvironment('REVENUE_CAT_API_KEY_ANDROID');

abstract interface class IPurchaseService {
  Future<void> init({String? userId});
  Future<List<AppProduct>> getProducts();
  Future<PurchaseResult> buySubscription(AppProduct product);
  Future<bool> restorePurchases();
  Future<bool> hasSubscription();
  bool isSubscribed(String productId);
  Future<bool> checkSubscription();
}

class PurchaseService with AppLogger implements IPurchaseService {
  factory PurchaseService({required AdsService ads}) => _instance ??= PurchaseService._internal(ads);

  PurchaseService._internal(this.ads);

  static PurchaseService? _instance;

  static const _tag = 'PurchaseService';

  final AdsService ads;

  List<String> _activeSubscriptions = [];

  late final _adsCallbacks = _SubscriptionCallbacks(onPurchased: _removeAds, onExpired: _reactivateAds);

  late final Map<String, _SubscriptionCallbacks> _purchaseCallbacks = {
    'io.purplesoft.azuredevops.subs.noads.monthly': _adsCallbacks,
    'io.purplesoft.azuredevops.subs.noads.yearly': _adsCallbacks,
    'azuredevops.subs.noads.monthly': _adsCallbacks,
    'azuredevops.subs.noads.yearly': _adsCallbacks,
    'rc_promo_noadsentitlement_monthly': _adsCallbacks,
    'rc_promo_noadsentitlement_yearly': _adsCallbacks,
  };

  void _removeAds() {
    ads.removeAds();
  }

  void _reactivateAds() {
    ads.reactivateAds();
  }

  @override
  Future<void> init({String? userId}) async {
    setTag(_tag);
    await _configureSDK(userId);
  }

  Future<void> _configureSDK(String? userId) async {
    await Purchases.setLogLevel(LogLevel.debug);

    final configuration = PurchasesConfiguration(Platform.isIOS ? _revenueCatApiKeyIos : _revenueCatApiKeyAndroid)
      ..appUserID = userId
      ..purchasesAreCompletedBy = const PurchasesAreCompletedByRevenueCat();

    await Purchases.configure(configuration);

    logDebug('Purchases configured with user id: $userId');
  }

  @override
  Future<List<AppProduct>> getProducts() async {
    final products = await Purchases.getProducts([
      // iOS
      'io.purplesoft.azuredevops.subs.noads.monthly',
      'io.purplesoft.azuredevops.subs.noads.yearly',
      // Android
      'azuredevops.subs.noads.monthly',
      'azuredevops.subs.noads.yearly',
    ]);

    logDebug('Products: ${products.length}');
    for (final product in products) {
      logDebug('Product: ${product.title}, ${product.description}, ${product.price}, ${product.identifier}');
    }

    return products
        .map(
          (product) => AppProduct(
            id: product.identifier,
            title: product.title,
            description: product.description,
            price: product.price,
            priceString: product.priceString,
            currencyCode: product.currencyCode,
            duration: product.subscriptionPeriod ?? '',
          ),
        )
        .toList();
  }

  @override
  Future<PurchaseResult> buySubscription(AppProduct product) async {
    try {
      final res = await Purchases.purchaseStoreProduct(
        StoreProduct(
          product.id,
          product.description,
          product.title,
          product.price,
          product.priceString,
          product.currencyCode,
        ),
      );

      logDebug('Purchase result: $res');
      return res.activeSubscriptions.contains(product.id) ? PurchaseResult.success : PurchaseResult.failed;
    } catch (e, s) {
      if (e is PlatformException && e.details['readableErrorCode'] == 'PURCHASE_CANCELLED') {
        logDebug('Purchase cancelled');
        return PurchaseResult.cancelled;
      }

      logError('Purchase failed: $e', s);

      return PurchaseResult.failed;
    }
  }

  @override
  Future<bool> restorePurchases() async {
    final info = await Purchases.restorePurchases();
    _activeSubscriptions = info.activeSubscriptions;
    return info.activeSubscriptions.isNotEmpty;
  }

  @override
  Future<bool> hasSubscription() async {
    final info = await Purchases.getCustomerInfo();
    logDebug('activeSubscriptions: ${info.activeSubscriptions}');

    _activeSubscriptions = [...info.activeSubscriptions];

    info.entitlements.active.forEach((key, value) {
      logDebug('entitlements: $key, $value');
    });

    _activeSubscriptions.addAll(info.entitlements.active.keys);

    final hasSub = _activeSubscriptions.isNotEmpty;

    if (hasSub) {
      _purchaseCallbacks[info.activeSubscriptions.first]?.onPurchased.call();
    } else {
      final expiredSubs = info.allExpirationDates.entries.sortedBy((e) => e.value ?? '').map((e) => e.key).toList();
      for (final callbacks in _purchaseCallbacks.entries) {
        if (expiredSubs.contains(callbacks.key)) {
          callbacks.value.onExpired.call();
        }
      }
    }

    return hasSub;
  }

  @override
  bool isSubscribed(String productId) => _activeSubscriptions.contains(productId);

  @override
  Future<bool> checkSubscription() {
    logDebug('Checking subscription');
    return hasSubscription();
  }
}

class _SubscriptionCallbacks {
  _SubscriptionCallbacks({required this.onPurchased, required this.onExpired});

  final VoidCallback onPurchased;
  final VoidCallback onExpired;
}

class AppProduct {
  const AppProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.priceString,
    required this.currencyCode,
    required this.duration,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String priceString;
  final String currencyCode;
  final String duration;
}

enum PurchaseResult {
  success,
  cancelled,
  failed,
}

class PurchaseServiceWidget extends InheritedWidget {
  const PurchaseServiceWidget({
    super.key,
    required super.child,
    required this.purchase,
  });

  final PurchaseService purchase;

  static PurchaseServiceWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PurchaseServiceWidget>()!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
