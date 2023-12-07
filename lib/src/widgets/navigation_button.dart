import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/theme/theme.dart';
import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  const NavigationButton({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(15),
    this.inkwellKey,
    this.backgroundColor,
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final ValueKey<String?>? inkwellKey;
  final Color? backgroundColor;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    Widget button = InkWell(
      key: inkwellKey,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? context.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (margin != null) {
      button = Padding(
        padding: margin!,
        child: button,
      );
    }

    return button;
  }
}
