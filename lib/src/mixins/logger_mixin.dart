import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

mixin AppLogger {
  /// Logs only if [kDebugMode]
  void logDebug(String msg) {
    if (kDebugMode) print(msg);
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
}
