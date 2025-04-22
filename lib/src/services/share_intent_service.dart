import 'dart:async';

import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/router/share_extension_router.dart';
import 'package:flutter/services.dart';

/// Handles URLs shared from Android Sharesheet.
class ShareIntentService with AppLogger {
  factory ShareIntentService() {
    return instance ??= ShareIntentService._();
  }

  ShareIntentService._() {
    setTag('ShareIntentService');
  }

  static ShareIntentService? instance;

  static const _shareExtensionChannel = MethodChannel('io.purplesoft.azuredevops.shareextension');

  Future<void> maybeHandleSharedUrl() async {
    final url = (await _shareExtensionChannel.invokeMethod('getSharedUrl')) as String? ?? '';
    logDebug('shared url: $url');
    if (url.isEmpty) return;

    unawaited(ShareExtensionRouter.handleRoute(Uri.parse(url)));
  }
}
