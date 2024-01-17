part of file_detail;

class _FileDetailController with ShareMixin {
  _FileDetailController._(this.apiService, this.args);

  final AzureApiService apiService;
  final RepoDetailArgs args;

  final fileContent = ValueNotifier<ApiResponse<FileDetailResponse?>?>(null);

  Future<void> init() async {
    final fileRes = await apiService.getFileDetail(
      projectName: args.projectName,
      repoName: args.repositoryName,
      path: args.filePath ?? '/',
      branch: args.branch,
    );

    fileContent.value = fileRes;
  }

  void shareFile() {
    shareUrl(_fileUrl);
  }

  String get _fileUrl =>
      '${apiService.basePath}/${args.projectName}/_git/${args.repositoryName}?path=${args.filePath}&version=GB${args.branch}';
}
