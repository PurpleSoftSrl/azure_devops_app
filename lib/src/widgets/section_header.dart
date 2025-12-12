import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.text,
    this.textHeight,
    this.iconSize,
    this.mainAxisAlignment = MainAxisAlignment.start,
  }) : icon = null,
       marginTop = 24;

  const SectionHeader.withIcon({
    required this.text,
    required this.icon,
    this.marginTop = 24,
    this.textHeight,
    this.iconSize,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  const SectionHeader.noMargin({
    required this.text,
    this.icon,
    this.textHeight,
    this.iconSize,
    this.mainAxisAlignment = MainAxisAlignment.start,
  }) : marginTop = 0;

  final String text;
  final IconData? icon;
  final double? iconSize;
  final double marginTop;
  final MainAxisAlignment mainAxisAlignment;

  /// Used to align [SectionHeader] inside a row
  final double? textHeight;

  @override
  Widget build(BuildContext context) {
    Widget body = Text(
      text,
      style: context.textTheme.headlineSmall!.copyWith(height: textHeight),
      overflow: TextOverflow.ellipsis,
    );

    if (icon != null) {
      body = Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Icon(icon, size: iconSize),
          const SizedBox(width: 12),
          Flexible(child: body),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: marginTop, bottom: 12),
      child: body,
    );
  }
}
