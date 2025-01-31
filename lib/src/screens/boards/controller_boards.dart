part of boards;

class _BoardsController {
  _BoardsController._(this.api);

  final AzureApiService api;

  final allProjects = ValueNotifier<ApiResponse<List<Project>?>?>(null);

  Future<void> init() async {
    final allProjectsRes = await api.getProjects();
    allProjects.value = allProjectsRes;
  }

  void goToProjectBoards(Project project) {
    AppRouter.goToProjectBoards(projectId: project.name!);
  }
}
