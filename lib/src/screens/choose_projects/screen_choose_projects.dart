part of choose_projects;

class _ChooseProjectsScreen extends StatelessWidget {
  const _ChooseProjectsScreen(this.ctrl, this.parameters);

  final _ChooseProjectsController ctrl;
  final _ChooseProjectsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppPageListenable<GetProjectsResponse?>(
          onRefresh: ctrl.init,
          dispose: ctrl.dispose,
          title: 'Choose projects',
          notifier: ctrl.chosenProjects,
          onEmpty: (_) => Text('No commits found'),
          safeAreaBottom: false,
          showScrollbar: true,
          builder: (projects) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Choose the projects that you want to follow.\nYou will see only info related to the projects that you choose.\nYou can change your choice any time from the settings.',
                  style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary, height: 1.6),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionHeader.noMargin(text: 'Projects'),
                  ValueListenableBuilder<bool>(
                    valueListenable: ctrl.chooseAll,
                    builder: (_, chooseAll, __) => Row(
                      children: [
                        Text(
                          chooseAll ? 'Unselect all' : 'Select all',
                          style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                        ),
                        Checkbox(
                          value: chooseAll,
                          onChanged: (_) => ctrl.toggleChooseAll(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ...ctrl.allProjects.map(
                (p) => CheckboxListTile(
                  title: Text(p.name!),
                  value: projects!.projects.contains(p),
                  onChanged: (_) => ctrl.toggleChosenProject(p),
                  contentPadding: EdgeInsets.only(right: 4),
                ),
              ),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: max(MediaQuery.of(context).padding.bottom, 24),
          right: 0,
          left: 0,
          child: ValueListenableBuilder<ApiResponse<GetProjectsResponse?>?>(
            valueListenable: ctrl.chosenProjects,
            builder: (_, projects, __) => projects?.data == null || projects!.data!.projects.isEmpty
                ? const SizedBox()
                : LoadingButton(
                    onPressed: ctrl.goToHome,
                    text: 'Confirm',
                  ),
          ),
        ),
      ],
    );
  }
}
