import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class TextTitleDescription extends StatelessWidget {
  const TextTitleDescription({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(
        children: [
          TextSpan(
            text: title,
            style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
          ),
          TextSpan(
            text: ' $description',
            style: context.textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
