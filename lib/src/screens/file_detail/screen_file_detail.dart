part of file_detail;

class _FileDetailScreen extends StatelessWidget {
  const _FileDetailScreen(this.ctrl, this.parameters);

  final _FileDetailController ctrl;
  final _FileDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPageListenable<FileDetailResponse?>(
      onRefresh: ctrl.init,
      dispose: ctrl.dispose,
      title: ctrl.args.filePath!.startsWith('/') ? ctrl.args.filePath!.substring(1) : ctrl.args.filePath!,
      notifier: ctrl.fileContent,
      onEmpty: (_) => Text('No file found'),
      padding: EdgeInsets.zero,
      builder: (res) => ctrl.args.filePath!.isImage
          ? Image.memory(
              Uint8List.fromList(res!.content.codeUnits),
            )
          : ctrl.args.filePath!.isMd
              ? Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: MarkdownBody(data: res!.content),
                )
              : res!.isBinary
                  ? Center(
                      child: const Text('Cannot display binary data'),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: context.height),
                        child: HighlightView(
                          res.content,
                          language: ctrl.args.filePath!.split('.').last,
                          theme: _customTheme(context),
                          padding: const EdgeInsets.only(left: 8),
                          textStyle: context.textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
    );
  }
}

Map<String, TextStyle> _customTheme(BuildContext context) => {
      'root': TextStyle(color: Colors.transparent, backgroundColor: Colors.transparent),
      'comment': TextStyle(color: Color(0xff999988), fontStyle: FontStyle.italic),
      'quote': TextStyle(color: Color(0xff999988), fontStyle: FontStyle.italic),
      'keyword': TextStyle(color: context.colorScheme.primary, fontWeight: FontWeight.normal),
      'selector-tag': TextStyle(color: Colors.green, fontWeight: FontWeight.normal),
      'subst': TextStyle(color: context.colorScheme.secondary, fontWeight: FontWeight.normal),
      'number': TextStyle(color: Colors.green),
      'literal': TextStyle(color: Colors.green),
      'variable': TextStyle(color: Colors.green),
      'template-variable': TextStyle(color: Color(0xff008080)),
      'string': TextStyle(color: context.colorScheme.secondary),
      'doctag': TextStyle(color: Color(0xffdd1144)),
      'title': TextStyle(color: Colors.green, fontWeight: FontWeight.normal),
      'section': TextStyle(color: context.colorScheme.primary, fontWeight: FontWeight.normal),
      'selector-id': TextStyle(color: context.colorScheme.primary, fontWeight: FontWeight.normal),
      'type': TextStyle(color: Color(0xff445588), fontWeight: FontWeight.normal),
      'tag': TextStyle(color: context.colorScheme.primaryContainer, fontWeight: FontWeight.normal),
      'name': TextStyle(color: context.colorScheme.secondary, fontWeight: FontWeight.normal),
      'attribute': TextStyle(color: context.colorScheme.primary, fontWeight: FontWeight.normal),
      'regexp': TextStyle(color: Color(0xff009926)),
      'link': TextStyle(color: Color(0xff009926)),
      'symbol': TextStyle(color: Color(0xff990073)),
      'bullet': TextStyle(color: Color(0xff990073)),
      'built_in': TextStyle(color: Colors.green),
      'builtin-name': TextStyle(color: Color(0xff0086b3)),
      'meta': TextStyle(color: Color(0xff999999), fontWeight: FontWeight.normal),
      'deletion': TextStyle(backgroundColor: Color(0xffffdddd)),
      'addition': TextStyle(backgroundColor: Color(0xffddffdd)),
      'emphasis': TextStyle(fontStyle: FontStyle.italic),
      'strong': TextStyle(fontWeight: FontWeight.normal),
    };

extension on String {
  bool get isImage {
    final extension = split('.').last.toLowerCase().trim();
    return ['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'].contains(extension);
  }

  bool get isMd {
    final extension = split('.').last.toLowerCase().trim();
    return extension == 'md';
  }
}
