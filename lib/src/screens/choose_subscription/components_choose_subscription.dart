part of choose_subscription;

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.product, required this.onTap, required this.isPurchasingThisProduct});

  final AppProduct product;
  final void Function(AppProduct) onTap;
  final bool isPurchasingThisProduct;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPurchasingThisProduct ? null : () => onTap(product),
      child: Stack(
        children: [
          Container(
            width: context.width,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isPurchasingThisProduct ? context.colorScheme.surface : null,
              gradient: product.isDefault
                  ? LinearGradient(
                      colors: [
                        context.colorScheme.primary,
                        isPurchasingThisProduct ? context.colorScheme.surface : Colors.transparent,
                      ],
                      stops: const [.15, .15],
                      begin: Alignment.topRight,
                      end: Alignment.bottomCenter,
                    )
                  : null,
              border: Border.all(
                color: product.isDefault ? context.colorScheme.primary : context.colorScheme.surface,
                width: 3,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: product.priceString,
                    style: context.textTheme.headlineLarge,
                    children: [
                      WidgetSpan(child: const SizedBox(width: 8)),
                      TextSpan(
                        text: '/${product.formattedDuration}',
                        style: context.textTheme.titleMedium!.copyWith(color: context.colorScheme.onSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(product.durationAsFrequency.titleCase, style: context.textTheme.titleLarge),
                const SizedBox(height: 10),
                Text(
                  product.durationDescription,
                  style: context.textTheme.labelMedium!.copyWith(color: context.colorScheme.onSecondary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(DevOpsIcons.success),
                    const SizedBox(width: 5),
                    Text(
                      product.description,
                      style: context.textTheme.labelMedium!.copyWith(color: context.colorScheme.onSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (product.isDefault) Positioned(right: 5, top: 5, child: const Icon(Icons.star_border_rounded, size: 24)),
        ],
      ),
    );
  }
}

extension on AppProduct {
  String get formattedDuration {
    if (duration.length != 3) return duration;

    final type = switch (duration[2].toLowerCase()) {
      'w' => 'week',
      'm' => 'month',
      'y' => 'year',
      _ => '',
    };

    return type;
  }

  String get durationAsFrequency {
    if (duration.length != 3) return duration;

    final type = switch (duration[2].toLowerCase()) {
      'w' => 'weekly',
      'm' => 'monthly',
      'y' => 'yearly',
      _ => '',
    };

    return type;
  }

  String get durationDescription {
    if (duration.length != 3) return duration;

    final type = switch (duration[2].toLowerCase()) {
      'm' => 'Pay monthly, cancel anytime.',
      'y' => 'Pay for a full year.',
      _ => '',
    };

    return type;
  }
}
