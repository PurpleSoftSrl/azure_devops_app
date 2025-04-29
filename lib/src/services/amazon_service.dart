import 'package:azure_devops/src/extensions/reponse_extension.dart';
import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/models/amazon/amazon_item.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart';
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

  var _lastFetchTime = DateTime.now();

  void dispose() {
    instance = null;
  }

  Future<List<AmazonItem>> getItems() async {
    if (_items != null && _lastFetchTime.isAfter(DateTime.now().subtract(Duration(hours: 1)))) return _items!;

    final allItems = <AmazonItem>[];

    for (final category in _categories) {
      final url = '$_basePath/api/products?category=$category';
      final Response jsonsRes;

      try {
        jsonsRes = await _client.get(Uri.parse(url));
      } catch (e, s) {
        logError(e, s);
        continue;
      }

      if (jsonsRes.isError) {
        logErrorMessage('Error fetching items for category: $category');
        continue;
      }

      final items = AmazonItem.listFromJson(jsonsRes.body);
      allItems.addAll(items);

      logDebug('Fetched ${items.length} items for category: $category.');
      _lastFetchTime = DateTime.now();
    }

    logDebug('Total items fetched: ${allItems.length}');

    final distinctItems = allItems
        .sorted((a, b) => (b.discount?.percentage ?? 0).compareTo(a.discount?.percentage ?? 0))
        .toSet()
        .toList();

    logDebug('Distinct items: ${distinctItems.length}');

    return _items = distinctItems;
  }
}
