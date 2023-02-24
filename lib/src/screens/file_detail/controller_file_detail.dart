part of file_detail;

class _FileDetailController {
  factory _FileDetailController({required AzureApiService apiService, required RepoDetailArgs args}) {
    return instance ??= _FileDetailController._(apiService, args);
  }

  _FileDetailController._(this.apiService, this.args);

  static _FileDetailController? instance;

  final AzureApiService apiService;
  final RepoDetailArgs args;

  final fileContent = ValueNotifier<ApiResponse<String>?>(null);

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    final fileRes = await apiService.getFileDetail(
      projectName: args.projectName,
      repoName: args.repositoryName,
      path: args.filePath ?? '/',
    );

    fileContent.value = fileRes;
  }
}
