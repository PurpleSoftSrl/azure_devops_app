import 'dart:developer';

import 'package:azure_devops/main.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

mixin AppLogger {
  /// Logs only if [kDebugMode]
  void logDebug(String msg) {
    if (kDebugMode) log(msg);
  }

  /// Logs on Sentry with level info only if ![kDebugMode]
  void logInfo(String msg) {
    if (kDebugMode) return;

    Sentry.captureMessage(msg);
  }

  /// Logs on Sentry with level error only if ![kDebugMode]
  void logError(Object? exception, Object stacktrace) {
    if (kDebugMode) return;

    Sentry.captureException(exception, stackTrace: stacktrace);
  }

  /// Logs on Firebase Analytics only if [useFirebase] is true
  void logAnalytics(String name, Map<String, Object?> parameters) {
    if (!useFirebase) return;

    const prefix = 'az_';
    final prefixedName = name.startsWith('az_') ? name : '$prefix$name';
    final prefixedParameters = <String, Object?>{};

    for (final entry in parameters.entries) {
      final oldKey = entry.key;
      final prefixedKey = oldKey.startsWith(prefix) ? oldKey : '$prefix$oldKey';

      final oldValue = entry.value;
      final value = (oldValue is String || oldValue is num) ? oldValue : oldValue.toString();
      prefixedParameters.putIfAbsent(prefixedKey, () => value);
    }

    FirebaseAnalytics.instance.logEvent(
      name: prefixedName,
      parameters: prefixedParameters,
    );
  }
}
