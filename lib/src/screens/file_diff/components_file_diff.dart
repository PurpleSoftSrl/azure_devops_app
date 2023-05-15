part of file_diff;

class _ImageDiff extends StatelessWidget {
  const _ImageDiff({required this.ctrl});

  final _FileDiffController ctrl;

  @override
  Widget build(BuildContext context) {
    const imageHeight = 300.0;
    return Column(
      children: [
        if (ctrl.previousImageDiffContent != null) ...[
          Text('Original'),
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
          Text('Modified'),
          const SizedBox(
            height: 5,
          ),
        ],
        _Image(
          imageBytes: ctrl.imageDiffContent!.codeUnits,
          imageHeight: imageHeight,
        ),
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
