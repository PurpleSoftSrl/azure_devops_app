import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:flutter/material.dart';

class DevOpsPopupMenu extends StatelessWidget {
  const DevOpsPopupMenu({
    required this.tooltip,
    required this.items,
    this.offset = const Offset(0, 40),
    this.child,
    this.color,
    this.constraints,
    this.menuKey,
  });

  final String tooltip;
  final List<PopupItem> Function() items;
  final Offset offset;
  final Widget? child;
  final Color? color;
  final BoxConstraints? constraints;
  final Key? menuKey;

  List<PopupMenuEntry<void>> _getEffectiveItems(BuildContext context) {
    final builtItems = items();
    final effectiveItems = <PopupMenuEntry<void>>[];

    for (final item in builtItems) {
      effectiveItems.add(
        PopupMenuItem<void>(
          onTap: item.onTap,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 30,
          child:
              item.child ??
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text(item.text, style: context.textTheme.titleSmall)),
                  Icon(item.icon),
                ],
              ),
        ),
      );

      if (item != builtItems.last) effectiveItems.add(const PopupMenuDivider());
    }

    return effectiveItems;
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      key: menuKey ?? ValueKey('Popup menu $tooltip'),
      itemBuilder: _getEffectiveItems,
      elevation: 5,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black,
      tooltip: tooltip,
      offset: offset,
      color: color,
      constraints: constraints,
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      child: child ?? Icon(DevOpsIcons.dots_horizontal),
    );
  }
}

class PopupItem {
  PopupItem({required this.text, this.icon, required this.onTap, this.child});

  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  final Widget? child;
}
