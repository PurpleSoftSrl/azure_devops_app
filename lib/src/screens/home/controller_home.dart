part of home;

class _HomeController {
  factory _HomeController({required AzureApiService apiService}) {
    return instance ??= _HomeController._(apiService);
  }

  _HomeController._(this.apiService) {
    init();
  }

  static _HomeController? instance;

  final AzureApiService apiService;

  final projects = ValueNotifier<ApiResponse<List<Project>>?>(null);

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    final alreadyChosenProjects = StorageServiceCore().getChosenProjects();

    alreadyChosenProjects.toList().sort((a, b) => b.lastUpdateTime!.compareTo(a.lastUpdateTime!));

    projects.value = ApiResponse.ok(alreadyChosenProjects.toList());
  }

  Future<void> goToCommits() async {
    await AppRouter.goToCommits();
  }

  Future<void> goToPipelines() async {
    await AppRouter.goToPipelines();
  }

  void goToWorkItems() {
    AppRouter.goToWorkItems();
  }

  void goToPullRequests() {
    AppRouter.goToPullRequests();
  }

  void goToChooseProjects() {
    AppRouter.goToChooseProjects();
  }

  void goToProjectDetail(Project p) {
    AppRouter.goToProjectDetail(p.name!);
  }
}
