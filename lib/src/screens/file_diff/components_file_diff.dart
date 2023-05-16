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
                      var oldLineNumber = b.oLine ?? -1;
                      final newLineNumber = b.mLine;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ctrl.isNotRealChange(b) && diff.originalFile != null)
                            ...b.mLines.map(
                              (l) => _NotEditedLine(
                                line: l,
                                lineNumber: oldLineNumber++,
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
                                  ),
                                _AddedLines(
                                  lines: b.mLines,
                                  newLineNumber: newLineNumber,
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
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (diff.modifiedFile != null) ...[
            Text(diff.modifiedFile!.contentMetadata.fileName),
            Text(
              diff.modifiedFile!.serverItem.startsWith('/')
                  ? diff.modifiedFile!.serverItem.substring(1)
                  : diff.modifiedFile!.serverItem,
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
  const _NotEditedLine({required this.line, required this.lineNumber});

  final String line;
  final int lineNumber;

  @override
  Widget build(BuildContext context) {
    return _DiffLine(
      line: line,
      lineNumber: lineNumber,
    );
  }
}

class _RemovedLines extends StatelessWidget {
  const _RemovedLines({required this.lines, required this.oldLineNumber});

  final List<String> lines;
  final int oldLineNumber;

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
            ),
          ),
        ],
      ),
    );
  }
}

class _AddedLines extends StatelessWidget {
  const _AddedLines({required this.lines, required this.newLineNumber});

  final List<String> lines;
  final int newLineNumber;

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
  });

  final int lineNumber;
  final String line;
  final bool isAdded;
  final bool isRemoved;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$lineNumber',
              style: context.textTheme.labelSmall!.copyWith(color: context.colorScheme.onSecondary),
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
