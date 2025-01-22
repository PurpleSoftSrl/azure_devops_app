part of choose_subscription;

class _ChooseSubscriptionController {
  _ChooseSubscriptionController._(this.purchase);

  final PurchaseService purchase;

  final products = ValueNotifier<ApiResponse<List<AppProduct>>?>(null);

  final isPurchasing = ValueNotifier<bool>(false);
  final purchasingMap = <String, ValueNotifier<bool>>{};

  Future<void> init() async {
    final productsRes = await purchase.getProducts();

    for (final product in productsRes) {
      purchasingMap[product.id] = ValueNotifier(false);
    }

    products.value = ApiResponse.ok(productsRes);
  }

  Future<void> purchaseProduct(AppProduct product) async {
    isPurchasing.value = true;
    purchasingMap[product.id]!.value = true;

    final res = await purchase.buySubscription(product);

    purchasingMap[product.id]!.value = false;
    isPurchasing.value = false;

    switch (res) {
      case PurchaseResult.success:
        OverlayService.snackbar('${product.title} subscription successfully purchased');
        unawaited(AppRouter.goToSplash());
        return;
      case PurchaseResult.failed:
        return OverlayService.error('Error', description: 'Subscription purchase failed');
      case PurchaseResult.cancelled:
    }
  }

  Future<void> restorePurchase() async {
    isPurchasing.value = true;

    final res = await purchase.restorePurchases();

    isPurchasing.value = false;

    if (!res) {
      return OverlayService.error('Error', description: 'No previous subscription found');
    }

    OverlayService.snackbar('Subscription successfully restored');
    unawaited(AppRouter.goToSplash());
    return;
  }
}
