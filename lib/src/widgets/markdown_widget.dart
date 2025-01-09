import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AppMarkdownWidget extends StatelessWidget {
  const AppMarkdownWidget({
    required this.data,
    this.styleSheet,
    this.onTapLink,
    this.shrinkWrap = true,
    this.paddingBuilders = const <String, MarkdownPaddingBuilder>{},
  });

  final String data;
  final MarkdownStyleSheet? styleSheet;
  final void Function(String, String?, String)? onTapLink;
  final bool shrinkWrap;
  final Map<String, MarkdownPaddingBuilder> paddingBuilders;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: MarkdownBody(
        data: data,
        styleSheet: styleSheet,
        onTapLink: onTapLink,
        shrinkWrap: shrinkWrap,
        paddingBuilders: paddingBuilders,
      ),
    );
  }
}
