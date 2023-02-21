part of file_diff;

class _FileDiffController {
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

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    final res = await apiService.getCommitDiff(
      commit: args.commit,
      filePath: args.filePath,
      isAdded: args.isAdded,
    );

    diff.value = res;
  }

  bool isNotRealChange(Block block) {
    return (block.truncatedAfter ?? false) || (block.truncatedBefore ?? false) || block.changeType == 0;
  }

  void shareDiff() {
    Share.share(diffUrl);
  }
}
