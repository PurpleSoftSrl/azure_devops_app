part of work_item_detail;

class _HtmlWidget extends StatelessWidget {
  const _HtmlWidget({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    return Html(
      data: data,
      style: {
        'div': Style.fromTextStyle(context.textTheme.labelSmall!),
      },
      onLinkTap: (str, _, __, ___) async {
        final url = str.toString();
        if (await canLaunchUrlString(url)) await launchUrlString(url);
      },
      customRenders: {
        (ctx) => ctx.tree.element?.localName == 'img': CustomRender.widget(
          widget: (ctx, child) {
            final image = CachedNetworkImage(
              imageUrl: ctx.tree.attributes['src']!,
              httpHeaders: apiService.headers,
              fit: BoxFit.contain,
              height: double.tryParse(ctx.tree.attributes['height'] ?? ''),
              width: double.tryParse(ctx.tree.attributes['width'] ?? ''),
              placeholder: (_, __) => Center(child: const CircularProgressIndicator()),
            );

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
          widget: (ctx, child) => const Text('\n'),
        ),
      },
    );
  }
}
