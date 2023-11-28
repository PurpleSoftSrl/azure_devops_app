part of file_diff;

/// Image diff, with original and modified version of the image.
class _ImageDiff extends StatelessWidget {
  const _ImageDiff({required this.ctrl});

  final _FileDiffController ctrl;

  @override
  Widget build(BuildContext context) {
    const imageHeight = 300.0;
    return Column(
      children: [
        if (ctrl.previousImageDiffContent != null) ...[
          Text(ctrl.imageDiffContent != null ? 'Original' : 'Deleted'),
          const SizedBox(
            height: 5,
          ),
          _Image(
            imageBytes: ctrl.previousImageDiffContent!.codeUnits,
            imageHeight: imageHeight,
          ),
          const SizedBox(
            height: 20,
          ),
        ],
        if (ctrl.imageDiffContent != null) ...[
          Text(ctrl.previousImageDiffContent != null ? 'Modified' : 'Added'),
          const SizedBox(
            height: 5,
          ),
          _Image(
            imageBytes: ctrl.imageDiffContent!.codeUnits,
            imageHeight: imageHeight,
          ),
        ],
      ],
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({
    required this.imageBytes,
    required this.imageHeight,
  });

  final List<int> imageBytes;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      Uint8List.fromList(imageBytes),
      height: imageHeight,
      frameBuilder: (_, child, frame, __) => frame == null
          ? SizedBox(
              height: imageHeight,
              child: Center(
                child: const CircularProgressIndicator(),
              ),
            )
          : child,
    );
  }
}

/// Normal file diff, with added/removed lines
class _FileDiff extends StatelessWidget {
  const _FileDiff({required this.ctrl, required this.diff});

  final _FileDiffController ctrl;
  final Diff diff;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: max(ctrl.diffMaxLength.toDouble() + 55, MediaQuery.of(context).size.width),
          minHeight: context.height,
        ),
        child: DefaultTextStyle(
          style: context.textTheme.titleSmall!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FileDiffHeader(
                diff: diff,
                ctrl: ctrl,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  ...diff.blocks.map(
                    (b) {
                      final oldLineNumber = b.oLine ?? -1;
                      var newLineNumber = b.mLine;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ctrl.isNotRealChange(b) && diff.originalFile != null)
                            ...b.mLines.map(
                              (l) => _NotEditedLine(
                                line: l,
                                lineNumber: newLineNumber++,
                                ctrl: ctrl,
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (diff.originalFile != null)
                                  _RemovedLines(
                                    lines: b.oLines,
                                    oldLineNumber: oldLineNumber,
                                    ctrl: ctrl,
                                  ),
                                _AddedLines(
                                  lines: b.mLines,
                                  newLineNumber: newLineNumber,
                                  ctrl: ctrl,
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
    );
  }
}

/// File name, path and added/removed line count.
class _FileDiffHeader extends StatelessWidget {
  const _FileDiffHeader({
    required this.diff,
    required this.ctrl,
  });

  final Diff diff;
  final _FileDiffController ctrl;

  @override
  Widget build(BuildContext context) {
    final file = diff.modifiedFile ?? diff.originalFile;
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (file != null) ...[
            Text(file.contentMetadata.fileName),
            Text(
              file.serverItem.startsWith('/') ? file.serverItem.substring(1) : file.serverItem,
              style: context.textTheme.labelSmall!.copyWith(color: context.colorScheme.onBackground.withOpacity(.6)),
            ),
          ],
          Row(
            children: [
              if (diff.originalFile != null &&
                  diff.blocks.fold(0, (a, b) => a + (ctrl.isNotRealChange(b) ? 0 : b.oLines.length)) > 0) ...[
                Icon(
                  Icons.remove,
                  size: 12,
                  color: Colors.red,
                ),
                Text(
                  diff.blocks.fold(0, (a, b) => a + (ctrl.isNotRealChange(b) ? 0 : b.oLines.length)).toString(),
                  style: context.textTheme.titleSmall!.copyWith(color: Colors.red),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
              if (diff.blocks.fold(0, (a, b) => a + (ctrl.isNotRealChange(b) ? 0 : b.mLines.length)) > 0) ...[
                Icon(
                  DevOpsIcons.plus,
                  size: 12,
                  color: Colors.green,
                ),
                Text(
                  diff.blocks.fold(0, (a, b) => a + (ctrl.isNotRealChange(b) ? 0 : b.mLines.length)).toString(),
                  style: context.textTheme.titleSmall!.copyWith(color: Colors.green),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _NotEditedLine extends StatelessWidget {
  const _NotEditedLine({required this.line, required this.lineNumber, required this.ctrl});

  final String line;
  final int lineNumber;
  final _FileDiffController ctrl;

  @override
  Widget build(BuildContext context) {
    return _DiffLine(
      line: line,
      lineNumber: lineNumber,
      ctrl: ctrl,
    );
  }
}

class _RemovedLines extends StatelessWidget {
  const _RemovedLines({required this.lines, required this.oldLineNumber, required this.ctrl});

  final List<String> lines;
  final int oldLineNumber;
  final _FileDiffController ctrl;

  @override
  Widget build(BuildContext context) {
    var lineNumber = oldLineNumber;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...lines.map(
            (ol) => _DiffLine(
              line: ol,
              lineNumber: lineNumber++,
              isRemoved: true,
              ctrl: ctrl,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddedLines extends StatelessWidget {
  const _AddedLines({required this.lines, required this.newLineNumber, required this.ctrl});

  final List<String> lines;
  final int newLineNumber;
  final _FileDiffController ctrl;

  @override
  Widget build(BuildContext context) {
    var lineNumber = newLineNumber;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...lines.map(
            (ml) => _DiffLine(
              line: ml,
              lineNumber: lineNumber++,
              isAdded: true,
              ctrl: ctrl,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiffLine extends StatelessWidget {
  const _DiffLine({
    required this.lineNumber,
    required this.line,
    this.isAdded = false,
    this.isRemoved = false,
    required this.ctrl,
  });

  final int lineNumber;
  final String line;
  final bool isAdded;
  final bool isRemoved;
  final _FileDiffController ctrl;

  @override
  Widget build(BuildContext context) {
    final isRightFile = isAdded || !isRemoved;

    final prThreadUpdate = ctrl.prThreads.firstWhereOrNull(
      (t) => (isRightFile ? t.threadContext!.rightFileStart : t.threadContext!.leftFileStart)?.line == lineNumber,
    );

    final hasCommentOnThisLine = prThreadUpdate != null && prThreadUpdate.comments.isNotEmpty;

    return Row(
      children: [
        GestureDetector(
          onTap: hasCommentOnThisLine || ctrl.args.pullRequestId == null
              ? null
              : () => ctrl.addPrComment(
                    lineNumber: lineNumber,
                    line: line,
                    isRightFile: isRightFile,
                  ),
          child: SizedBox(
            width: 30,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$lineNumber',
                    style: context.textTheme.labelSmall!.copyWith(color: context.colorScheme.onSecondary),
                  ),
                ),
                if (hasCommentOnThisLine)
                  _PrThread(
                    lineNumber: lineNumber,
                    prThreadUpdate: prThreadUpdate,
                    ctrl: ctrl,
                    line: line,
                    isRightFile: isRightFile,
                  ),
              ],
            ),
          ),
        ),
        if (isAdded || isRemoved) ...[
          const SizedBox(
            width: 5,
          ),
          SizedBox(
            width: 10,
            child: Icon(
              isAdded ? DevOpsIcons.plus : Icons.remove,
              size: 12,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
        ] else
          const SizedBox(
            width: 25,
          ),
        Text(
          line,
          style: context.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _PrThread extends StatelessWidget {
  const _PrThread({
    required this.lineNumber,
    required this.prThreadUpdate,
    required this.ctrl,
    required this.line,
    required this.isRightFile,
  });

  final int lineNumber;
  final ThreadUpdate prThreadUpdate;
  final _FileDiffController ctrl;
  final String line;
  final bool isRightFile;

  @override
  Widget build(BuildContext context) {
    return DevOpsPopupMenu(
      tooltip: 'pr comment line $lineNumber',
      offset: Offset.zero,
      color: context.colorScheme.surface,
      constraints: BoxConstraints(maxWidth: double.maxFinite),
      items: () => [
        PopupItem(
          text: prThreadUpdate.content,
          onTap: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: prThreadUpdate.comments
                .map(
                  (c) => Column(
                    children: [
                      PullRequestCommentCard(
                        onEditComment: !ctrl.canEditPrComment(c)
                            ? null
                            : () => ctrl.editPrComment(
                                  c,
                                  threadId: prThreadUpdate.id,
                                ),
                        onAddComment: () => ctrl.addPrComment(
                          threadId: prThreadUpdate.id,
                          parentCommentId: c.id,
                          lineNumber: lineNumber,
                          line: line,
                          isRightFile: isRightFile,
                        ),
                        onDeleteComment: !ctrl.canEditPrComment(c)
                            ? null
                            : () => ctrl.deletePrComment(c, threadId: prThreadUpdate.id),
                        comment: c,
                        threadId: prThreadUpdate.id,
                        borderRadiusBottom: prThreadUpdate.comments.length < 2 || c == prThreadUpdate.comments.last,
                        borderRadiusTop: prThreadUpdate.comments.length < 2 || c == prThreadUpdate.comments.first,
                      ),
                      if (c != prThreadUpdate.comments.last) const Divider(height: 10),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
      child: MemberAvatar(
        tappable: false,
        radius: 15,
        userDescriptor: prThreadUpdate.author.descriptor,
      ),
    );
  }
}
