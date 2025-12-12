part of choose_subscription;

class _ChooseSubscriptionScreen extends StatelessWidget {
  const _ChooseSubscriptionScreen(this.ctrl, this.parameters);

  final _ChooseSubscriptionController ctrl;
  final _ChooseSubscriptionParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<List<AppProduct>>(
      init: ctrl.init,
      title: 'Choose plan',
      notifier: ctrl.products,
      builder: (products) {
        final purchasedProducts = products.where((p) => ctrl.purchase.isSubscribed(p.id));
        final availableProducts = products.where((p) => !ctrl.purchase.isSubscribed(p.id));
        final titleStyle = context.textTheme.titleLarge;

        return ValueListenableBuilder(
          valueListenable: ctrl.isPurchasing,
          builder: (_, isPurchasing, _) => IgnorePointer(
            ignoring: isPurchasing,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (purchasedProducts.isNotEmpty) ...[
                  Text('Current Plan', style: titleStyle),
                  const SizedBox(height: 18),
                  ...purchasedProducts.map(
                    (p) => ValueListenableBuilder(
                      valueListenable: ctrl.purchasingMap[p.id]!,
                      builder: (_, isPurchasing, _) => _SubscriptionCard(
                        product: p,
                        onTap: (_) => OverlayService.snackbar('You are already subscribed to ${p.title}'),
                        isPurchasingThisProduct: isPurchasing,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                if (availableProducts.isNotEmpty) ...[
                  Text('Available', style: titleStyle),
                  const SizedBox(height: 18),
                  ...availableProducts.map(
                    (p) => ValueListenableBuilder(
                      valueListenable: ctrl.purchasingMap[p.id]!,
                      builder: (_, isPurchasing, _) => _SubscriptionCard(
                        product: p,
                        onTap: ctrl.purchaseProduct,
                        isPurchasingThisProduct: isPurchasing,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                LoadingButton(
                  onPressed: ctrl.restorePurchase,
                  text: 'Restore purchase',
                  backgroundColor: Colors.transparent,
                  textColor: context.colorScheme.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
