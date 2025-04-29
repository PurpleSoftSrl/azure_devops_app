import 'package:azure_devops/src/extensions/reponse_extension.dart';
import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/models/amazon/amazon_item.dart';
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

  void dispose() {
    instance = null;
  }

  Future<List<AmazonItem>> getItems() async {
    if (_items != null) return _items!;

    // TODO handle multiple categories
    final url = 'https://products.azdevops.app/api/products?category=computers';
    final jsonsRes = await _client.get(Uri.parse(url));
    if (jsonsRes.isError) return [];

    final items = AmazonItem.listFromJson(jsonsRes.body);
    logDebug('Fetched ${items.length} items.');

    return _items = items;
  }
}
