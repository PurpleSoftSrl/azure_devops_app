part of choose_projects;

class _ChooseProjectsController {
  factory _ChooseProjectsController({required AzureApiService apiService, required bool removeRoutes}) {
    return instance ??= _ChooseProjectsController._(apiService, removeRoutes);
  }

  _ChooseProjectsController._(this.apiService, this.removeRoutes);

  static _ChooseProjectsController? instance;

  final AzureApiService apiService;
  final bool removeRoutes;

  final chosenProjects = ValueNotifier<ApiResponse<GetProjectsResponse?>?>(null);
  List<Project> allProjects = <Project>[];

  final chooseAll = ValueNotifier(false);

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    final org = StorageServiceCore().getOrganization();
    if (org.isEmpty) {
      await _chooseOrg();
    }

    allProjects = [];

    final projectsRes = await apiService.getProjects();
    final projects = projectsRes.data ?? [];

    final alreadyChosenProjects = StorageServiceCore().getChosenProjects();

    // sort projects by last change date, already chosen projects go first.
    if (alreadyChosenProjects.isNotEmpty) {
      allProjects
        ..addAll(alreadyChosenProjects.toList()..sort((a, b) => b.lastUpdateTime!.compareTo(a.lastUpdateTime!)))
        ..addAll(
          projects.where((p) => !alreadyChosenProjects.contains(p)).toList()
            ..sort((a, b) => b.lastUpdateTime!.compareTo(a.lastUpdateTime!)),
        );
    } else {
      allProjects.addAll(projects..sort((a, b) => b.lastUpdateTime!.compareTo(a.lastUpdateTime!)));
      chooseAll.value = true;
    }

    chosenProjects.value = ApiResponse.ok(
      GetProjectsResponse(projects: (alreadyChosenProjects.isNotEmpty ? alreadyChosenProjects : projects).toList()),
    );
  }

  void toggleChooseAll() {
    chosenProjects.value = ApiResponse.ok(GetProjectsResponse(projects: chooseAll.value ? [] : allProjects));

    chooseAll.value = !chooseAll.value;
  }

  void toggleChosenProject(Project p) {
    if (chosenProjects.value!.data!.projects.contains(p)) {
      chosenProjects.value!.data!.projects.remove(p);
    } else {
      chosenProjects.value!.data!.projects.add(p);
    }

    chosenProjects.value = ApiResponse.ok(GetProjectsResponse(projects: chosenProjects.value!.data!.projects));
  }

  Future<void> goToHome() async {
    if (chosenProjects.value!.data!.projects.isEmpty) {
      return AlertService.error(
        'No projects chosen',
        description: 'You have to choose at least one project',
      );
    }

    apiService.setChosenProjects(chosenProjects.value!.data!.projects);

    if (removeRoutes) {
      unawaited(AppRouter.goToTabs());
    } else {
      AppRouter.popRoute();
    }
  }

  // ignore: long-method
  Future<void> _chooseOrg() async {
    final orgsRes = await apiService.getOrganizations();
    if (orgsRes.isError) {
      return AlertService.error(
        'Error trying to get your organizations',
        description: "Check that your token has 'All accessible organizations' option enabled",
      );
    }

    final orgs = orgsRes.data!;

    if (orgs.isEmpty) {
      return AlertService.error(
        'No organizations found for your account',
        description: "Check that your token has 'All accessible organizations' option enabled",
      );
    }

    if (orgs.length < 2) {
      await apiService.setOrganization(orgs.first.accountName!);
      return;
    }

    Organization? selectedOrg;

    await showModalBottomSheet(
      context: AppRouter.rootNavigator!.context,
      backgroundColor: AppRouter.rootNavigator!.context.colorScheme.background,
      isDismissible: false,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text('Select your organization'),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  ...orgs.map(
                    (u) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: LoadingButton(
                        onPressed: () {
                          selectedOrg = u;
                          AppRouter.popRoute();
                        },
                        text: u.accountName!,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (selectedOrg == null) return;

    await apiService.setOrganization(selectedOrg!.accountName!);
  }
}
