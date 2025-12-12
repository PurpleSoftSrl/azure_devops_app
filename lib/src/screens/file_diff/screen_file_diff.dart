part of file_diff;

class _FileDiffScreen extends StatelessWidget {
  const _FileDiffScreen(this.ctrl, this.parameters);

  final _FileDiffController ctrl;
  final _FileDiffParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<Diff?>(
      init: ctrl.init,
      title: 'File diff',
      actions: [IconButton(onPressed: ctrl.shareDiff, icon: Icon(DevOpsIcons.share))],
      notifier: ctrl.diff,
      padding: EdgeInsets.zero,
      showScrollbar: true,
      builder: (diff) => switch (diff) {
        final Diff d when d.imageComparison && ctrl.isImageDiff => _ImageDiff(ctrl: ctrl),
        final Diff d when d.binaryContent => const Center(child: Text('Cannot show binary file diff')),
        _ => _FileDiff(ctrl: ctrl, diff: diff!),
      },
    );
  }
}
