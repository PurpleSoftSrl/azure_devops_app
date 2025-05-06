import 'package:azure_devops/src/extensions/reponse_extension.dart';
import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/models/amazon/amazon_item.dart';
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

  static const _url = 'https://products.azdevops.app/api/products?category=all';

  var _lastFetchTime = DateTime.now();

  void dispose() {
    instance = null;
  }

  Future<List<AmazonItem>> getItems() async {
    if (_items != null && _hasFetchedRecently()) return _items!;

    final Response jsonsRes;

    try {
      jsonsRes = await _client.get(Uri.parse(_url));
    } catch (e, s) {
      logError(e, s);
      return [];
    }

    if (jsonsRes.isError) {
      logErrorMessage('Error fetching items');
      return [];
    }

    _lastFetchTime = DateTime.now();

    final items = AmazonItem.listFromJson(jsonsRes.body);
    logDebug('Fetched ${items.length} items.');

    return _items = items;
  }

  bool _hasFetchedRecently() => _lastFetchTime.isAfter(DateTime.now().subtract(Duration(hours: 1)));
}
