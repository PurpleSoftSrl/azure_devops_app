part of choose_subscription;

class _ChooseSubscriptionController {
  _ChooseSubscriptionController._();

  final products = ValueNotifier<ApiResponse<List<AppProduct>>?>(null);

  final purchasingMap = <String, ValueNotifier<bool>>{};

  Future<void> init() async {
    final productsRes = await PurchaseService().getProducts();

    for (final product in productsRes) {
      purchasingMap[product.id] = ValueNotifier(false);
    }

    products.value = ApiResponse.ok(productsRes);
  }

  Future<void> purchase(AppProduct product) async {
    purchasingMap[product.id]!.value = true;

    final res = await PurchaseService().buySubscription(product);

    purchasingMap[product.id]!.value = false;

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
    final res = await PurchaseService().restorePurchases();
    if (!res) {
      return OverlayService.error('Error', description: 'No previous subscription found');
    }

    OverlayService.snackbar('Subscription successfully restored');
    unawaited(AppRouter.goToSplash());
    return;
  }
}
