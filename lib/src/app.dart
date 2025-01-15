import 'package:azure_devops/main.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/screens/splash/base_splash.dart';
import 'package:azure_devops/src/services/ads_service.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:azure_devops/src/services/purchase_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:azure_devops/src/widgets/lifecycle_listener.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:purple_theme/purple_theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AzureDevOps extends StatelessWidget {
  const AzureDevOps({super.key});

  @override
  Widget build(BuildContext context) {
    return PurpleTheme(
      child: AdsServiceWidget(
        ads: AdsService(),
        child: PurchaseServiceWidget(
          purchase: PurchaseService(ads: AdsService()),
          child: AzureApiServiceInherited(
            apiService: AzureApiServiceImpl(),
            child: StorageServiceInherited(
              storageService: StorageServiceCore(),
              // LifecycleListener must be below AzureApiServiceInherited because it depends on it
              child: LifecycleListener(
                child: Builder(
                  builder: (_) {
                    // builder is needed to switch theme
                    return GestureDetector(
                      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                      child: MaterialApp(
                        navigatorKey: AppRouter.navigatorKey,
                        routes: AppRouter.routes,
                        theme: AppTheme.lightTheme,
                        darkTheme: AppTheme.darkTheme,
                        debugShowCheckedModeBanner: false,
                        scaffoldMessengerKey: OverlayService.scaffoldMessengerKey,
                        navigatorObservers: [
                          SentryNavigatorObserver(),
                          if (useFirebase)
                            FirebaseAnalyticsObserver(
                              analytics: FirebaseAnalytics.instance,
                              routeFilter: (route) => route?.settings.name != null && route!.settings.name != '/',
                            ),
                        ],
                        home: const SplashPage(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
