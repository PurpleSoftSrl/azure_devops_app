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
          widget: (ctx, child) => Image.network(
            ctx.tree.attributes['src']!,
            headers: apiService.headers,
            fit: BoxFit.contain,
            height: double.tryParse(ctx.tree.attributes['height'] ?? ''),
            width: double.tryParse(ctx.tree.attributes['width'] ?? ''),
            frameBuilder: (_, child, frame, __) =>
                frame == null ? Center(child: const CircularProgressIndicator()) : child,
          ),
        ),
        (ctx) => ctx.tree.element?.localName == 'br': CustomRender.widget(
          widget: (ctx, child) => const Text('\n'),
        ),
      },
    );
  }
}
