import 'dart:async';
import 'dart:convert';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
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
    final apiService = AzureApiServiceInherited.of(context).apiService;
    final defaultTextStyle = context.textTheme.labelMedium!;
    final effectiveStyle = style ?? defaultTextStyle;
    final htmlTextStyle = Style.fromTextStyle(effectiveStyle).copyWith(margin: Margins.zero, padding: padding);

    return Html(
      data: data,
      style: {
        'div': htmlTextStyle,
        'p': htmlTextStyle,
        'body': htmlTextStyle,
        'html': htmlTextStyle,
      },
      onLinkTap: (str, _, __, ___) async {
        final url = str.toString();
        if (await canLaunchUrlString(url)) await launchUrlString(url);
      },
      customRenders: {
        (ctx) => ctx.tree.element?.localName == 'img': CustomRender.widget(
          widget: (ctx, child) {
            final src = ctx.tree.attributes['src'];
            if (src == null) return const SizedBox();

            final isNetworkImage = src.startsWith('http');
            final isBase64 = src.startsWith('data:');

            Widget image;
            if (isNetworkImage) {
              image = CachedNetworkImage(
                imageUrl: src,
                httpHeaders: apiService.headers,
                fit: BoxFit.contain,
                height: double.tryParse(ctx.tree.attributes['height'] ?? ''),
                width: double.tryParse(ctx.tree.attributes['width'] ?? ''),
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
        (ctx) => ctx.tree.element?.localName == 'br': CustomRender.widget(
          widget: (ctx, child) => const Text(''),
        ),
        (ctx) =>
            ctx.tree.element?.localName == 'a' &&
            ctx.tree.attributes['data-vss-mention'] != null &&
            ctx.tree.element!.innerHtml.startsWith('@'): CustomRender.widget(
          widget: (ctx, child) => GestureDetector(
            onTap: () async {
              final name = ctx.tree.element!.innerHtml.substring(1);
              final user = await apiService.getUserFromDisplayName(name: name);
              if (user.isError) return;

              unawaited(AppRouter.goToMemberDetail(user.data!.descriptor!));
            },
            child: Text(
              ctx.tree.element!.innerHtml,
              style: effectiveStyle.copyWith(color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
        ),
        (ctx) =>
            ctx.tree.element?.localName == 'a' &&
            ctx.tree.attributes['data-vss-mention'] != null &&
            ctx.tree.element!.innerHtml.startsWith('#'): CustomRender.widget(
          widget: (ctx, child) => GestureDetector(
            onTap: () {
              final url = ctx.tree.attributes['href'];
              if (url == null) return;

              final project = url.substring(0, url.indexOf('/_workitems')).split('/').lastOrNull;
              if (project == null) return;

              final id = url.split('/').lastOrNull;
              if (id == null) return;

              final parsedId = int.tryParse(id);
              if (parsedId == null) return;

              AppRouter.goToWorkItemDetail(project: project, id: parsedId);
            },
            child: Text(
              ctx.tree.element!.innerHtml,
              style: effectiveStyle.copyWith(color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
        ),
        (ctx) => // pr link
            ctx.tree.element?.localName == 'a' &&
            ctx.tree.attributes['data-vss-mention'] != null &&
            ctx.tree.attributes['href'] != null &&
            ctx.tree.attributes['href']!.startsWith(apiService.basePath) &&
            ctx.tree.attributes['href']!.contains('/pullrequest/'): CustomRender.widget(
          widget: (ctx, child) => GestureDetector(
            onTap: () {
              final url = ctx.tree.attributes['href'];
              if (url == null) return;

              final project = url.substring(0, url.indexOf('/_git')).split('/').lastOrNull;
              if (project == null) return;

              final repository = url.substring(0, url.indexOf('/pullrequest')).split('/').lastOrNull;
              if (repository == null) return;

              final id = url.split('/').lastOrNull;
              if (id == null) return;

              final parsedId = int.tryParse(id.substring(0, id.indexOf('?')));
              if (parsedId == null) return;

              AppRouter.goToPullRequestDetail(project: project, repository: repository, id: parsedId);
            },
            child: Text(
              ctx.tree.element!.innerHtml,
              style: effectiveStyle.copyWith(color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
        ),
        (ctx) => // pr mention
            ctx.tree.element?.localName == 'a' &&
            ctx.tree.attributes['data-vss-mention'] != null &&
            ctx.tree.element!.innerHtml.startsWith('Pull Request '): CustomRender.widget(
          widget: (ctx, child) => GestureDetector(
            onTap: () {
              final url = ctx.tree.attributes['data-vss-mention']!;

              final parts = url.split(':');

              final project = parts[4];
              final repository = parts[5];
              final id = int.tryParse(parts[6]);
              if (id == null) return;

              AppRouter.goToPullRequestDetail(project: project, repository: repository, id: id);
            },
            child: Text(
              ctx.tree.element!.innerHtml,
              style: effectiveStyle.copyWith(color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
        ),
      },
    );
  }
}
