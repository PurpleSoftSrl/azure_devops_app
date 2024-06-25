import 'dart:async';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/form_field.dart';
import 'package:azure_devops/src/widgets/navigation_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverlayService {
  OverlayService._();

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static BuildContext get context => AppRouter.rootNavigator!.context;

  // ignore: long-method
  static Future<bool> confirm(String title, {String? description}) async {
    var res = false;

    await showCupertinoDialog(
      context: context,
      routeSettings: RouteSettings(name: 'alert_${title}_$description'),
      builder: (ctx) => Center(
        child: AlertDialog(
          surfaceTintColor: context.themeExtension.background,
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
                        foregroundColor: WidgetStatePropertyAll(context.colorScheme.onPrimary),
                        backgroundColor: WidgetStatePropertyAll(Colors.transparent),
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
                        backgroundColor: WidgetStatePropertyAll(context.colorScheme.primary),
                        foregroundColor: WidgetStatePropertyAll(context.colorScheme.onPrimary),
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
    await showCupertinoDialog(
      context: context,
      routeSettings: RouteSettings(name: 'alert_${title}_$description'),
      builder: (ctx) => Center(
        child: AlertDialog(
          surfaceTintColor: context.themeExtension.background,
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
                  backgroundColor: WidgetStatePropertyAll(context.colorScheme.primary),
                  foregroundColor: WidgetStatePropertyAll(context.colorScheme.onPrimary),
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

  // ignore: long-parameter-list, long-method
  static Future<void> bottomsheet({
    required WidgetBuilder builder,
    bool isDismissible = true,
    bool isScrollControlled = false,
    String? title,
    double heightPercentage = .8,
    EdgeInsets padding = const EdgeInsets.all(15),
    bool spaceUnderTitle = true,
    Widget? topRight,
    String? name,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: context.themeExtension.background,
      useRootNavigator: true,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      routeSettings: RouteSettings(name: 'bs_${name ?? title}'),
      builder: (ctx) => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
        ),
        child: Container(
          height: context.height * heightPercentage,
          decoration: BoxDecoration(
            color: context.themeExtension.background,
          ),
          child: Scaffold(
            body: Padding(
              padding: padding,
              child: Column(
                children: [
                  if (title != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                          width: 80,
                        ),
                        Flexible(child: Text(title)),
                        SizedBox(
                          width: 80,
                          child: topRight ??
                              (isDismissible
                                  ? Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: AppRouter.popRoute,
                                        child: Icon(Icons.close),
                                      ),
                                    )
                                  : null),
                        ),
                      ],
                    ),
                  if (spaceUnderTitle)
                    const SizedBox(
                      height: 20,
                    ),
                  Expanded(child: builder(ctx)),
                ],
              ),
            ),
          ),
        ),
      ),
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
        content: NavigationButton(
          onTap: scaffoldMessengerKey.currentState!.hideCurrentMaterialBanner,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          backgroundColor: isError ? context.colorScheme.error : context.colorScheme.surface,
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
        actions: const [Text('')],
        elevation: 5,
        onVisible: () =>
            Timer(Duration(seconds: 3), () => scaffoldMessengerKey.currentState!.hideCurrentMaterialBanner()),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static Future<String?> formBottomsheet({required String title, required String label, String? initialValue}) async {
    var result = '';
    var hasConfirmed = false;

    await OverlayService.bottomsheet(
      title: title,
      isScrollControlled: true,
      builder: (_) => DevOpsFormField(
        onChanged: (s) => result = s,
        label: label,
        initialValue: initialValue,
      ),
      topRight: Builder(
        builder: (context) => TextButton(
          onPressed: () {
            hasConfirmed = true;
            AppRouter.popRoute();
          },
          style: TextButtonTheme.of(context).style!.copyWith(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
          child: Text(
            'Confirm',
            style: context.textTheme.bodyMedium!.copyWith(color: context.colorScheme.primary),
          ),
        ),
      ),
    );
    if (result.isEmpty || !hasConfirmed) return null;

    return result;
  }
}
