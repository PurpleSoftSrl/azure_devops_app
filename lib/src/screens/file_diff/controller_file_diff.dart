part of file_diff;

class _FileDiffController with ShareMixin {
  factory _FileDiffController({required AzureApiService apiService, required FileDiffArgs args}) {
    return instance ??= _FileDiffController._(apiService, args);
  }

  _FileDiffController._(this.apiService, this.args);

  static _FileDiffController? instance;

  final AzureApiService apiService;
  final FileDiffArgs args;

  final diff = ValueNotifier<ApiResponse<Diff?>?>(null);

  String get diffUrl =>
      '${apiService.basePath}/${args.commit.projectName}/_git/${args.commit.repositoryName}/commit/${args.commit.commitId}';

  /// Used to calculate text width to avoid layout issues.
  int diffMaxLength = -1;

  String? imageDiffContent;
  String? previousImageDiffContent;

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    final res = await apiService.getCommitDiff(
      commit: args.commit,
      filePath: args.filePath,
      isAdded: args.isAdded,
      isDeleted: args.isDeleted,
    );

    if (res.data != null) {
      final maxLengthM = res.data!.blocks.map((e) => e.mLines).expand((l) => l).fold(0, (a, b) {
        final size = _getTextWidth(b);
        return a > size ? a : size;
      });

      final maxLengthO = res.data!.blocks.map((e) => e.oLines).expand((l) => l).fold(0, (a, b) {
        final size = _getTextWidth(b);
        return a > size ? a : size;
      });

      final maxLength = max(maxLengthM, maxLengthO);

      diffMaxLength = maxLength;
    }

    final isImage = res.data?.imageComparison ?? false;

    if (isImage) {
      if (!args.isDeleted) {
        final imageRes = await apiService.getFileDetail(
          projectName: args.commit.projectName,
          repoName: args.commit.repositoryName,
          path: args.filePath,
          commitId: args.commit.commitId,
        );

        imageDiffContent = imageRes.data?.content;
      }

      if (!args.isAdded) {
        final previousImageRes = await apiService.getFileDetail(
          projectName: args.commit.projectName,
          repoName: args.commit.repositoryName,
          path: args.filePath,
          commitId: args.commit.commitId,
          previousChange: true,
        );

        previousImageDiffContent = previousImageRes.data?.content;
      }
    }

    diff.value = res;
  }

  bool isNotRealChange(Block block) {
    return (block.truncatedAfter ?? false) || (block.truncatedBefore ?? false) || block.changeType == 0;
  }

  void shareDiff() {
    shareUrl(diffUrl);
  }

  int _getTextWidth(String b) {
    return (TextPainter(
      text: TextSpan(text: b.trimRight(), style: AppRouter.navigatorKey.currentContext!.textTheme.titleSmall!),
      maxLines: 1,
      textScaleFactor: MediaQuery.of(AppRouter.navigatorKey.currentContext!).textScaleFactor,
      textDirection: TextDirection.ltr,
    )..layout())
        .size
        .width
        .toInt();
  }
}
