import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class ShortcutLabel extends StatelessWidget {
  const ShortcutLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.textTheme.bodyMedium,
      textAlign: TextAlign.center,
    );
  }
}
