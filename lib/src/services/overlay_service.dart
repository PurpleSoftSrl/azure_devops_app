import 'dart:async';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverlayService {
  OverlayService._();

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // ignore: long-method
  static Future<bool> confirm(String title, {String? description}) async {
    final context = AppRouter.rootNavigator!.context;

    var res = false;

    await showCupertinoDialog(
      context: context,
      routeSettings: RouteSettings(name: 'alert_$title'),
      builder: (ctx) => Center(
        child: AlertDialog(
          title: Text(
            title,
            style: context.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (description != null)
                Text(
                  description,
                  style: context.textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: AppRouter.popRoute,
                      style: ButtonStyle(
                        foregroundColor: MaterialStatePropertyAll(context.colorScheme.onPrimary),
                        backgroundColor: MaterialStatePropertyAll(Colors.transparent),
                      ),
                      child: Text(
                        'Cancel',
                        style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        res = true;
                        AppRouter.popRoute();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(context.colorScheme.primary),
                        foregroundColor: MaterialStatePropertyAll(context.colorScheme.onPrimary),
                      ),
                      child: Text(
                        'Confirm',
                        style: context.textTheme.titleSmall!.copyWith(
                          color: context.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return res;
  }

  static Future<void> error(String title, {String? description}) async {
    final context = AppRouter.rootNavigator!.context;

    await showCupertinoDialog(
      context: context,
      routeSettings: RouteSettings(name: 'alert_$title'),
      builder: (ctx) => Center(
        child: AlertDialog(
          title: Text(
            title,
            style: context.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (description != null)
                SelectableText(
                  description,
                  style: context.textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(
                height: 40,
              ),
              TextButton(
                onPressed: AppRouter.popRoute,
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(context.colorScheme.primary),
                  foregroundColor: MaterialStatePropertyAll(context.colorScheme.onPrimary),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Close',
                    style: context.textTheme.titleSmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> bottomsheet({
    required WidgetBuilder builder,
    bool isDismissible = true,
    bool isScrollControlled = false,
    required String title,
  }) async {
    final context = AppRouter.rootNavigator!.context;

    await showModalBottomSheet(
      context: context,
      backgroundColor: context.colorScheme.background,
      useRootNavigator: true,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      routeSettings: RouteSettings(name: 'bs_$title'),
      builder: builder,
    );
  }

  /// Debouncer to avoid showing too many snackbars.
  static bool _isShowingSnackbar = false;

  static void snackbar(String title, {bool isError = false}) {
    if (_isShowingSnackbar) return;

    _isShowingSnackbar = true;
    Timer(Duration(seconds: 2), () => _isShowingSnackbar = false);

    scaffoldMessengerKey.currentState!.showMaterialBanner(
      MaterialBanner(
        content: InkWell(
          onTap: scaffoldMessengerKey.currentState!.hideCurrentMaterialBanner,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isError
                  ? AppRouter.rootNavigator!.context.colorScheme.error
                  : AppRouter.rootNavigator!.context.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title)),
                const SizedBox(
                  width: 10,
                ),
                Icon(isError ? DevOpsIcons.failed : DevOpsIcons.success),
              ],
            ),
          ),
        ),
        actions: [Text('')],
        elevation: 5,
        onVisible: () =>
            Timer(Duration(seconds: 3), () => scaffoldMessengerKey.currentState!.hideCurrentMaterialBanner()),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
