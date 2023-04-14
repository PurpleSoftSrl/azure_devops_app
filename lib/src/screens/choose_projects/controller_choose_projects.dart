part of choose_projects;

class _ChooseProjectsController {
  factory _ChooseProjectsController({
    required AzureApiService apiService,
    required bool removeRoutes,
    required StorageService storageService,
  }) {
    return instance ??= _ChooseProjectsController._(apiService, removeRoutes, storageService);
  }

  _ChooseProjectsController._(this.apiService, this.removeRoutes, this.storageService);

  static _ChooseProjectsController? instance;

  final AzureApiService apiService;
  final bool removeRoutes;
  final StorageService storageService;

  final chosenProjects = ValueNotifier<ApiResponse<GetProjectsResponse?>?>(null);
  List<Project> allProjects = <Project>[];

  final chooseAll = ValueNotifier(false);

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    final org = storageService.getOrganization();
    if (org.isEmpty) {
      await _chooseOrg();
    }

    allProjects = [];

    final projectsRes = await apiService.getProjects();
    final projects = projectsRes.data ?? [];

    final alreadyChosenProjects =
        storageService.getChosenProjects().where((p) => projects.map((p1) => p1.id!).contains(p.id!));

    // sort projects by last change date, already chosen projects go first.
    if (alreadyChosenProjects.isNotEmpty) {
      allProjects
        ..addAll(
          alreadyChosenProjects.toList()..sort((a, b) => b.lastUpdateTime!.compareTo(a.lastUpdateTime!)),
        )
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
      return OverlayService.error(
        'No projects chosen',
        description: 'You have to choose at least one project',
      );
    }

    apiService.setChosenProjects(
      chosenProjects.value!.data!.projects..sort((a, b) => b.lastUpdateTime!.compareTo(a.lastUpdateTime!)),
    );

    if (removeRoutes) {
      unawaited(AppRouter.goToTabs());
    } else {
      AppRouter.popRoute();
    }
  }

  Future<void> _chooseOrg() async {
    final orgsRes = await apiService.getOrganizations();
    if (orgsRes.isError) {
      return OverlayService.error(
        'Error trying to get your organizations',
        description: "Check that your token has 'All accessible organizations' option enabled",
      );
    }

    final orgs = orgsRes.data!;

    if (orgs.isEmpty) {
      return OverlayService.error(
        'No organizations found for your account',
        description: "Check that your token has 'All accessible organizations' option enabled",
      );
    }

    if (orgs.length < 2) {
      await apiService.setOrganization(orgs.first.accountName!);
      return;
    }

    final selectedOrg = await _selectOrganization(orgs);

    if (selectedOrg == null) return;

    await apiService.setOrganization(selectedOrg.accountName!);
  }

  Future<Organization?> _selectOrganization(List<Organization> orgs) async {
    Organization? selectedOrg;

    await OverlayService.bottomsheet(
      isDismissible: false,
      title: 'Select your organization',
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
    return selectedOrg;
  }
}
