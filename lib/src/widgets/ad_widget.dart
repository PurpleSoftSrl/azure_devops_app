import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/num_extension.dart';
import 'package:azure_devops/src/models/amazon/amazon_item.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher_string.dart';

typedef AdWithKey = ({AdWithView ad, GlobalKey key});

class CustomAdWidget extends StatelessWidget {
  const CustomAdWidget({required this.item});

  final Object item;

  @override
  Widget build(BuildContext context) {
    return switch (item) {
      final AmazonItem amazonItem => AmazonAdWidget(item: amazonItem),
      final AdWithKey adWithKey => NativeAdWidget(ad: adWithKey),
      _ => const SizedBox(),
    };
  }
}

class NativeAdWidget extends StatelessWidget {
  const NativeAdWidget({required this.ad});

  final AdWithKey ad;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Padding(
        padding: const EdgeInsets.only(top: 32),
        child: AdWidget(
          key: ad.key,
          ad: ad.ad,
        ),
      ),
    );
  }
}

class AmazonAdWidget extends StatelessWidget {
  const AmazonAdWidget({required this.item});

  final AmazonItem item;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = item.discount != null && item.discount!.amount > 0;
    return SizedBox(
      height: 160,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Center(
          child: GestureDetector(
            onTap: () => launchUrlString(item.itemUrl, mode: LaunchMode.externalApplication),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    item.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (hasDiscount) ...[
                            Text(
                              '-${item.discount!.percentage.toPercentage()}',
                              style: context.textTheme.bodyMedium!.copyWith(
                                color: context.colorScheme.error,
                                fontWeight: FontWeight.normal,
                                fontFamily: AppTheme.defaultFont,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.discountedPrice.amount.toCurrency(item.currency),
                              style: context.textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            item.originalPrice.amount.toCurrency(item.currency),
                            style: context.textTheme.bodySmall?.copyWith(
                              decoration: hasDiscount ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          if (item.isPrime) ...[
                            const Spacer(),
                            SvgPicture.network(
                              'https://m.media-amazon.com/images/G/29/perc/prime-logo.png',
                              width: 45,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
