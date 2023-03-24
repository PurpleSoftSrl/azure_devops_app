import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverlayService {
  OverlayService._();

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
}
