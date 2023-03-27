import 'package:azure_devops/src/app.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purple_theme/purple_theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await StorageServiceCore().init();

  PurpleThemeHandler().init(
    defaultTheme: AppTheme.darkTheme,
    allThemes: AppTheme.allThemes,
  );

  final sentryDns = const String.fromEnvironment('SENTRY_DNS');

  if (sentryDns.isEmpty) {
    runApp(const AzureDevOps());
  } else {
    await SentryFlutter.init(
      (options) {
        options
          ..dsn = sentryDns
          ..reportSilentFlutterErrors = true
          ..debug = false
          ..enableAppLifecycleBreadcrumbs = true
          ..enableAutoNativeBreadcrumbs = false
          ..enableUserInteractionBreadcrumbs = true
          ..maxBreadcrumbs = 500
          ..attachScreenshot = true
          ..tracesSampler = (samplingContext) {
            if (kDebugMode) return null;
            return 1;
          }
          ..beforeSend = (evt, {hint}) {
            print('[sentry] ${evt.exceptions?[0].value}');
            if (kDebugMode) return null;
            return evt..tags?.putIfAbsent('hint', () => hint.toString());
          };
      },
      appRunner: () async {
        runApp(
          SentryScreenshotWidget(
            child: SentryUserInteractionWidget(
              child: const AzureDevOps(),
            ),
          ),
        );
      },
    );
  }
}
