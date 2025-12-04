import 'dart:developer';

import 'package:azure_devops/firebase_options.dart';
import 'package:azure_devops/src/app.dart';
import 'package:azure_devops/src/services/ads_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purple_theme/purple_theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

const useFirebase = bool.fromEnvironment('FIREBASE');
const _sentryDns = String.fromEnvironment('SENTRY_DNS');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (useFirebase) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await StorageServiceCore().init();

  PurpleThemeHandler().init(defaultTheme: AppTheme.darkTheme, allThemes: AppTheme.allThemes);

  // ignore: unawaited_futures, to speed up app start
  AdsServiceImpl().init();

  if (_sentryDns.isEmpty || kDebugMode) {
    runApp(const AzureDevOps());
  } else {
    await SentryFlutter.init(
      (options) {
        options
          ..dsn = _sentryDns
          ..reportSilentFlutterErrors = true
          ..debug = false
          ..enableAppLifecycleBreadcrumbs = true
          ..enableAutoNativeBreadcrumbs = false
          ..enableUserInteractionBreadcrumbs = true
          ..maxBreadcrumbs = 500
          ..attachScreenshot = true
          ..screenshotQuality = SentryScreenshotQuality.low
          ..tracesSampler = (samplingContext) {
            if (kDebugMode) return null;
            return 1;
          }
          ..beforeSend = (evt, hint) {
            if (kDebugMode) {
              log('[sentry] ${evt.exceptions?.firstOrNull?.value}');
              return null;
            }

            // ignore: switch_on_type
            switch (evt.throwable.runtimeType.toString()) {
              case 'HttpExceptionWithStatus':
              case 'ClientException':
              case '_ClientSocketException':
              case 'NetworkImageLoadException':
                return null;
            }

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
