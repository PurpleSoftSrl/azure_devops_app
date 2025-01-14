part of choose_subscription;

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({
    required this.product,
    required this.onTap,
    required this.isPurchasing,
  });

  final AppProduct product;
  final void Function(AppProduct) onTap;
  final bool isPurchasing;

  @override
  Widget build(BuildContext context) {
    final productTitle = Platform.isIOS ? product.title : product.title.substring(0, product.title.indexOf('(') - 1);
    return GestureDetector(
      onTap: isPurchasing ? null : () => onTap(product),
      child: Container(
        height: 120,
        width: context.width,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: context.colorScheme.primary,
        ),
        child: isPurchasing
            ? Center(
                child: CircularProgressIndicator(
                  color: context.colorScheme.onPrimary,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$productTitle (${product.formattedDuration}) ${product.priceString}',
                    style: context.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: context.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}

extension on AppProduct {
  String get formattedDuration {
    if (duration.length != 3) return duration;

    final number = num.tryParse(duration[1]);
    final type = switch (duration[2].toLowerCase()) {
      'w' => 'week',
      'm' => 'month',
      'y' => 'year',
      _ => '',
    };

    return '$number $type';
  }
}
