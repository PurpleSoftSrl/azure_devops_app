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
          : res!.isBinary
              ? Center(
                  child: const Text('Cannot display binary data'),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    res.content,
                    style: context.textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
    );
  }
}

extension on String {
  bool get isImage {
    final extension = split('.').last.toLowerCase().trim();
    return ['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'].contains(extension);
  }
}
