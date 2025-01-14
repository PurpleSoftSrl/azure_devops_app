part of choose_subscription;

class _ChooseSubscriptionScreen extends StatelessWidget {
  const _ChooseSubscriptionScreen(this.ctrl, this.parameters);

  final _ChooseSubscriptionController ctrl;
  final _ChooseSubscriptionParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<List<AppProduct>>(
      init: ctrl.init,
      title: 'Choose subscription',
      notifier: ctrl.products,
      builder: (products) {
        final purchasedProducts = products.where((p) => PurchaseService().isSubscribed(p.id));
        final availableProducts = products.where((p) => !PurchaseService().isSubscribed(p.id));
        final titleStyle = context.textTheme.bodyLarge;

        return Column(
          children: [
            if (purchasedProducts.isNotEmpty) ...[
              Text(
                'Purchased',
                style: titleStyle,
              ),
              const SizedBox(height: 8),
              ...purchasedProducts.map(
                (p) => ValueListenableBuilder(
                  valueListenable: ctrl.purchasingMap[p.id]!,
                  builder: (_, isPurchasing, __) => _SubscriptionCard(
                    product: p,
                    onTap: (_) => OverlayService.snackbar('You are already subscribed to ${p.title}'),
                    isPurchasing: isPurchasing,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
            if (availableProducts.isNotEmpty) ...[
              Text(
                'Available',
                style: titleStyle,
              ),
              const SizedBox(height: 8),
              ...availableProducts.map(
                (p) => ValueListenableBuilder(
                  valueListenable: ctrl.purchasingMap[p.id]!,
                  builder: (_, isPurchasing, __) => _SubscriptionCard(
                    product: p,
                    onTap: ctrl.purchase,
                    isPurchasing: isPurchasing,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
            LoadingButton(
              onPressed: ctrl.restorePurchase,
              text: 'Restore purchase',
              backgroundColor: Colors.transparent,
              textColor: context.colorScheme.primary,
            ),
          ],
        );
      },
    );
  }
}
