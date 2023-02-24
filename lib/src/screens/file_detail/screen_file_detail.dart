part of file_detail;

class _FileDetailScreen extends StatelessWidget {
  const _FileDetailScreen(this.ctrl, this.parameters);

  final _FileDetailController ctrl;
  final _FileDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPageListenable<String?>(
      onRefresh: ctrl.init,
      dispose: ctrl.dispose,
      title: ctrl.args.filePath!.startsWith('/') ? ctrl.args.filePath!.substring(1) : ctrl.args.filePath!,
      notifier: ctrl.fileContent,
      onEmpty: (_) => Text('No file found'),
      builder: (items) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          items ?? '',
          style: context.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
