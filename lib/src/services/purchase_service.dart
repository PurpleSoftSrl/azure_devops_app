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

abstract interface class PurchaseService {
  ValueNotifier<String> get entitlementName;
  Future<void> init({String? userId, String? userName});
  Future<List<AppProduct>> getProducts();
  Future<PurchaseResult> buySubscription(AppProduct product);
  Future<bool> restorePurchases();
  Future<bool> hasSubscription();
  bool isSubscribed(String productId);
  Future<bool> checkSubscription();
}

class PurchaseServiceImpl with AppLogger implements PurchaseService {
  factory PurchaseServiceImpl({required AdsService ads}) => _instance ??= PurchaseServiceImpl._internal(ads);

  PurchaseServiceImpl._internal(this.ads);

  static PurchaseServiceImpl? _instance;

  static const _tag = 'PurchaseService';

  final AdsService ads;

  static const _noAdsYearly = 'azuredevops.subs.noads.yearly';
  static const _noAdsMonthly = 'azuredevops.subs.noads.monthly';

  static const _noAdsEntitlement = 'noadsentitlement';

  late final _adsCallbacks = _SubscriptionCallbacks(onPurchased: _removeAds, onExpired: _reactivateAds, name: 'No Ads');

  late final Map<String, _SubscriptionCallbacks> _purchaseCallbacks = {
    _noAdsEntitlement: _adsCallbacks,
  };

  List<String> _activeSubscriptions = [];
  List<StoreProduct> _products = [];

  @override
  ValueNotifier<String> get entitlementName => _entitlementName;
  final _entitlementName = ValueNotifier<String>('');

  void _removeAds() {
    ads.removeAds();
  }

  void _reactivateAds() {
    ads.reactivateAds();
  }

  @override
  Future<void> init({String? userId, String? userName}) async {
    setTag(_tag);

    try {
      await _configureSDK(userId, userName);
    } catch (e, s) {
      logError('Failed to configure Purchases SDK: $e', s);
    }
  }

  Future<void> _configureSDK(String? userId, String? userName) async {
    await Purchases.setLogLevel(LogLevel.debug);

    final configuration = PurchasesConfiguration(Platform.isIOS ? _revenueCatApiKeyIos : _revenueCatApiKeyAndroid)
      ..appUserID = userId
      ..purchasesAreCompletedBy = const PurchasesAreCompletedByRevenueCat();

    await Purchases.configure(configuration);

    if (userId != null) await Purchases.setEmail(userId);
    if (userName != null) await Purchases.setDisplayName(userName);

    logDebug('Purchases configured with user id: $userId');
  }

  @override
  Future<List<AppProduct>> getProducts() async {
    _products = await Purchases.getProducts([_noAdsMonthly, _noAdsYearly]);

    for (final product in _products) {
      logDebug('Product: ${product.title}, ${product.description}, ${product.price}, ${product.identifier}');
    }

    return _products
        .map(
          (product) => AppProduct(
            id: product.identifier,
            title: product.title,
            description: product.description,
            price: product.price,
            priceString: product.priceString,
            currencyCode: product.currencyCode,
            duration: product.subscriptionPeriod ?? '',
            isDefault: product.identifier.startsWith(_noAdsYearly),
          ),
        )
        .sorted((p1, p2) => p1.isDefault ? -1 : 1)
        .toList();
  }

  @override
  Future<PurchaseResult> buySubscription(AppProduct product) async {
    try {
      final storeProduct = _products.firstWhere((p) => p.identifier == product.id);
      final res = await Purchases.purchase(PurchaseParams.storeProduct(storeProduct));

      logDebug('Purchase result: $res');
      return res.customerInfo.activeSubscriptions.isNotEmpty ? PurchaseResult.success : PurchaseResult.failed;
    } catch (e, s) {
      if (e is PlatformException &&
          ['PURCHASE_CANCELLED', 'PurchaseCancelledError'].contains(e.details?['readableErrorCode'])) {
        logDebug('Purchase cancelled');
        return PurchaseResult.cancelled;
      }

      logError('Purchase failed: $e', s);

      return PurchaseResult.failed;
    }
  }

  @override
  Future<bool> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      _activeSubscriptions = [...info.activeSubscriptions];
      return info.activeSubscriptions.isNotEmpty;
    } catch (e, s) {
      logError('Failed to restore purchases: $e', s);
      return false;
    }
  }

  @override
  Future<bool> hasSubscription() async {
    final info = await Purchases.getCustomerInfo();
    logDebug('activeSubscriptions: ${info.activeSubscriptions}');
    _activeSubscriptions = [...info.activeSubscriptions];

    info.entitlements.active.forEach((key, value) => logDebug('entitlements: $key, $value'));

    final hasSub = info.entitlements.active.containsKey(_noAdsEntitlement);

    if (hasSub) {
      _purchaseCallbacks[_noAdsEntitlement]?.onPurchased.call();
      _entitlementName.value = _purchaseCallbacks[_noAdsEntitlement]?.name ?? '';
    } else {
      _entitlementName.value = '';
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
  _SubscriptionCallbacks({
    required this.onPurchased,
    required this.onExpired,
    required this.name,
  });

  final VoidCallback onPurchased;
  final VoidCallback onExpired;
  final String name;
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
    required this.isDefault,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String priceString;
  final String currencyCode;
  final String duration;
  final bool isDefault;
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
