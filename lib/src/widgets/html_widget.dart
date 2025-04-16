import 'dart:async';
import 'dart:convert';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HtmlWidget extends StatelessWidget {
  const HtmlWidget({required this.data, this.padding = EdgeInsets.zero, this.style});

  final String data;
  final EdgeInsets padding;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final api = context.api;
    final defaultTextStyle = context.textTheme.labelMedium!;
    final effectiveStyle = style ?? defaultTextStyle;
    final htmlTextStyle = Style.fromTextStyle(effectiveStyle).copyWith(
      margin: Margins.zero,
      padding: HtmlPaddings(
        top: HtmlPadding(padding.top),
        right: HtmlPadding(padding.right),
        bottom: HtmlPadding(padding.bottom),
        left: HtmlPadding(padding.left),
      ),
    );

    // workaround to avoid layout error (https://github.com/flutter/flutter/issues/135912)
    RenderObject.debugCheckingIntrinsics = true;

    return SelectionArea(
      child: Html(
        data: data,
        style: {
          'div': htmlTextStyle,
          'p': htmlTextStyle,
          'body': htmlTextStyle,
          'html': htmlTextStyle,
        },
        onLinkTap: (str, _, __) async {
          final url = str.toString();
          if (await canLaunchUrlString(url)) await launchUrlString(url);
        },
        extensions: [
          TagExtension(
            tagsToExtend: {'img'},
            builder: (ctx) {
              final src = ctx.attributes['src'];
              if (src == null) return const SizedBox();

              final isNetworkImage = src.startsWith('http');
              final isBase64 = src.startsWith('data:');

              Widget image;
              if (isNetworkImage) {
                image = CachedNetworkImage(
                  imageUrl: src,
                  httpHeaders: api.headers,
                  fit: BoxFit.contain,
                  height: double.tryParse(ctx.attributes['height'] ?? ''),
                  width: double.tryParse(ctx.attributes['width'] ?? ''),
                  placeholder: (_, __) => Center(child: const CircularProgressIndicator()),
                );
              } else if (isBase64) {
                final data = src.split(',').last;
                image = Image.memory(base64Decode(data));
              } else {
                image = const SizedBox();
              }

              late OverlayEntry entry;

              void exitFullScreen() {
                entry.remove();
              }

              void goFullScreen() {
                entry = OverlayEntry(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      actions: [
                        CloseButton(
                          onPressed: exitFullScreen,
                        ),
                      ],
                    ),
                    body: InteractiveViewer(
                      child: SizedBox(
                        height: context.height,
                        width: context.width,
                        child: image,
                      ),
                    ),
                  ),
                );

                Overlay.of(context).insert(entry);
              }

              return GestureDetector(
                onTap: goFullScreen,
                child: image,
              );
            },
          ),
          TagExtension(
            tagsToExtend: {'br'},
            builder: (_) => const Text(''),
          ),
          TagExtension(
            tagsToExtend: {'a'},
            builder: (ctx) {
              final innerHtml = ctx.element!.innerHtml;

              final linkChild = Text(
                innerHtml,
                style: effectiveStyle.copyWith(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.blue,
                ),
              );

              final mention = ctx.attributes['data-vss-mention'];
              if (mention == null) return linkChild;

              final href = ctx.attributes['href'];

              // user mention
              if (innerHtml.startsWith('@')) {
                return GestureDetector(
                  onTap: () async {
                    final name = innerHtml.substring(1);
                    final user = await api.getUserFromDisplayName(name: name);
                    if (user.isError) return;

                    unawaited(AppRouter.goToMemberDetail(user.data!.descriptor!));
                  },
                  child: linkChild,
                );
              }

              // work item mention
              if (innerHtml.startsWith('#')) {
                return GestureDetector(
                  onTap: () {
                    final url = (href?.endsWith('/') ?? false) ? href?.substring(0, href.length - 1) : href;
                    if (url == null) return;

                    final project = url.substring(0, url.indexOf('/_workitems')).split('/').lastOrNull;
                    if (project == null) return;

                    final id = url.split('/').lastOrNull;
                    if (id == null) return;

                    final parsedId = int.tryParse(id);
                    if (parsedId == null) return;

                    AppRouter.goToWorkItemDetail(project: project, id: parsedId);
                  },
                  child: linkChild,
                );
              }

              // pr link
              if (href != null && href.contains('/pullrequest/')) {
                return GestureDetector(
                  onTap: () {
                    final url = href.endsWith('/') ? href.substring(0, href.length - 1) : href;

                    final project = url.substring(0, url.indexOf('/_git')).split('/').lastOrNull;
                    if (project == null) return;

                    final repository = url.substring(0, url.indexOf('/pullrequest')).split('/').lastOrNull;
                    if (repository == null) return;

                    final id = url.split('/').lastOrNull;
                    if (id == null) return;

                    final parsedId = int.tryParse(id);
                    if (parsedId == null) return;

                    AppRouter.goToPullRequestDetail(project: project, repository: repository, id: parsedId);
                  },
                  child: linkChild,
                );
              }

              return linkChild;
            },
          ),
        ],
      ),
    );
  }
}
