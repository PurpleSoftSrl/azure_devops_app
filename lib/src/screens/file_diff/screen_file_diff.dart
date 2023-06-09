part of file_diff;

class _FileDiffScreen extends StatelessWidget {
  const _FileDiffScreen(this.ctrl, this.parameters);

  final _FileDiffController ctrl;
  final _FileDiffParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<Diff?>(
      init: ctrl.init,
      dispose: ctrl.dispose,
      title: 'File diff',
      actions: [
        IconButton(
          onPressed: ctrl.shareDiff,
          icon: Icon(DevOpsIcons.share),
        ),
      ],
      notifier: ctrl.diff,
      padding: EdgeInsets.zero,
      showScrollbar: true,
      builder: (diff) =>
          diff!.imageComparison && (ctrl.imageDiffContent != null || ctrl.previousImageDiffContent != null)
              ? _ImageDiff(ctrl: ctrl)
              : diff.binaryContent
                  ? const Center(child: Text('Cannot show binary file diff'))
                  : _FileDiff(ctrl: ctrl, diff: diff),
    );
  }
}
