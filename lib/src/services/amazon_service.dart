import 'package:azure_devops/src/extensions/reponse_extension.dart';
import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/models/amazon/amazon_item.dart';
import 'package:collection/collection.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AmazonService with AppLogger {
  factory AmazonService() {
    return instance ??= AmazonService._();
  }

  AmazonService._() {
    setTag('AmazonService');
  }

  static AmazonService? instance;

  final _client = SentryHttpClient();

  List<AmazonItem>? _items;

  static const _categories = [
    'computers',
    'electronics',
  ];

  static const _basePath = 'https://products.azdevops.app';

  void dispose() {
    instance = null;
  }

  Future<List<AmazonItem>> getItems() async {
    if (_items != null) return _items!;

    final allItems = <AmazonItem>[];

    for (final category in _categories) {
      final url = '$_basePath/api/products?category=$category';
      final jsonsRes = await _client.get(Uri.parse(url));

      if (jsonsRes.isError) {
        logErrorMessage('Error fetching items for category: $category');
        continue;
      }

      final items = AmazonItem.listFromJson(jsonsRes.body);
      allItems.addAll(items);

      logDebug('Fetched ${items.length} items for category: $category.');
    }

    logDebug('Total items fetched: ${allItems.length}');

    return _items = allItems.sorted((a, b) => (b.discount?.percentage ?? 0).compareTo(a.discount?.percentage ?? 0));
  }
}
