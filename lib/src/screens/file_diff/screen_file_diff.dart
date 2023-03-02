part of file_diff;

class _FileDiffScreen extends StatelessWidget {
  const _FileDiffScreen(this.ctrl, this.parameters);

  final _FileDiffController ctrl;
  final _FileDiffParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPageListenable<Diff?>(
      onRefresh: ctrl.init,
      dispose: ctrl.dispose,
      title: 'File diff',
      actions: [
        IconButton(
          onPressed: ctrl.shareDiff,
          icon: Icon(DevOpsIcons.share),
        ),
      ],
      notifier: ctrl.diff,
      onEmpty: (_) => Text('No diff found'),
      padding: EdgeInsets.zero,
      showScrollbar: true,
      builder: (diff) => diff!.binaryContent
          ? Center(child: Text('Cannot show binary file diff'))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 2000, minHeight: context.height),
                child: DefaultTextStyle(
                  style: context.textTheme.titleSmall!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(diff.modifiedFile.contentMetadata.fileName),
                            Text(
                              diff.modifiedFile.serverItem.startsWith('/')
                                  ? diff.modifiedFile.serverItem.substring(1)
                                  : diff.modifiedFile.serverItem,
                              style: context.textTheme.labelSmall!
                                  .copyWith(color: context.colorScheme.onBackground.withOpacity(.6)),
                            ),
                            Row(
                              children: [
                                if (diff.originalFile != null &&
                                    diff.blocks
                                            .fold(0, (a, b) => a + (ctrl.isNotRealChange(b) ? 0 : b.oLines!.length)) >
                                        0) ...[
                                  Icon(
                                    Icons.remove,
                                    size: 12,
                                    color: Colors.red,
                                  ),
                                  Text(
                                    diff.blocks
                                        .fold(0, (a, b) => a + (ctrl.isNotRealChange(b) ? 0 : b.oLines!.length))
                                        .toString(),
                                    style: context.textTheme.titleSmall!.copyWith(color: Colors.red),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                                if (diff.blocks.fold(0, (a, b) => a + (ctrl.isNotRealChange(b) ? 0 : b.mLines.length)) >
                                    0) ...[
                                  Icon(
                                    DevOpsIcons.plus,
                                    size: 12,
                                    color: Colors.green,
                                  ),
                                  Text(
                                    diff.blocks
                                        .fold(0, (a, b) => a + (ctrl.isNotRealChange(b) ? 0 : b.mLines.length))
                                        .toString(),
                                    style: context.textTheme.titleSmall!.copyWith(color: Colors.green),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          ...diff.blocks.map(
                            (b) {
                              var oldLineNumber = b.oLine ?? -1;
                              var newLineNumber = b.mLine;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (ctrl.isNotRealChange(b) && diff.originalFile != null)
                                    ...b.mLines.map(
                                      (l) => Row(
                                        children: [
                                          SizedBox(
                                            width: 30,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                '${oldLineNumber++}',
                                                style: context.textTheme.labelSmall!
                                                    .copyWith(color: context.colorScheme.onSecondary),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 25,
                                          ),
                                          Text(
                                            l,
                                            style: context.textTheme.bodySmall!.copyWith(
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (diff.originalFile != null)
                                          Container(
                                            width: double.maxFinite,
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(.4),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                ...b.oLines!.map(
                                                  (ol) => Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 30,
                                                        child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Text(
                                                            '${oldLineNumber++}',
                                                            style: context.textTheme.labelSmall!
                                                                .copyWith(color: context.colorScheme.onSecondary),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                        child: Icon(
                                                          Icons.remove,
                                                          size: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        ol,
                                                        style: context.textTheme.bodySmall!.copyWith(
                                                          fontWeight: FontWeight.normal,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        Container(
                                          width: double.maxFinite,
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(.4),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ...b.mLines.map(
                                                (ml) => Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 30,
                                                      child: Align(
                                                        alignment: Alignment.centerRight,
                                                        child: Text(
                                                          '${newLineNumber++}',
                                                          style: context.textTheme.labelSmall!
                                                              .copyWith(color: context.colorScheme.onSecondary),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                      child: Icon(
                                                        DevOpsIcons.plus,
                                                        size: 12,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      ml,
                                                      style: context.textTheme.bodySmall!.copyWith(
                                                        fontWeight: FontWeight.normal,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  if ((b.truncatedAfter ?? false) && b != diff.blocks.last)
                                    Divider(
                                      height: 40,
                                      thickness: 1,
                                      color: context.colorScheme.surface,
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
