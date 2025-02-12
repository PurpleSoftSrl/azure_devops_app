part of boards;

class _BoardsController {
  _BoardsController._(this.storage);

  final StorageService storage;

  final allProjects = ValueNotifier<ApiResponse<List<Project>?>?>(null);

  Future<void> init() async {
    final allProjectsRes = storage.getChosenProjects().toList();
    allProjects.value = ApiResponse.ok(allProjectsRes);
  }

  void goToProjectBoards(Project project) {
    AppRouter.goToProjectBoards(projectId: project.name!);
  }
}
