part of choose_projects;

class _ChooseProjectsScreen extends StatelessWidget {
  const _ChooseProjectsScreen(this.ctrl, this.parameters);

  final _ChooseProjectsController ctrl;
  final _ChooseProjectsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => ctrl.onPopInvoked(didPop: didPop),
      child: Stack(
        children: [
          AppPage<List<Project>?>(
            init: ctrl.init,
            title: 'Choose projects',
            notifier: ctrl.chosenProjects,
            safeAreaBottom: false,
            showScrollbar: true,
            showBackButton: false,
            builder: (projects) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'You will see only info related to the projects that you choose.\nYou can change your choice any time from the settings.',
                    style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary, height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                if (ctrl.allProjects.length > projectsCountThreshold)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DevOpsSearchField(
                      autofocus: false,
                      onChanged: ctrl.setVisibleProjects,
                      onResetSearch: ctrl.resetSearch,
                      hint: 'Search by name',
                    ),
                  ),
                ValueListenableBuilder(
                  valueListenable: ctrl.visibleProjects,
                  builder: (context, visibleProjects, _) => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SectionHeader.noMargin(
                            text: 'Projects',
                            textHeight: 1,
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: ctrl.chooseAllVisible,
                            builder: (_, chooseAllVisible, __) => Row(
                              children: [
                                Text(
                                  chooseAllVisible ? 'Unselect all' : 'Select all',
                                  style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                                ),
                                Checkbox(
                                  value: chooseAllVisible,
                                  onChanged: (_) => ctrl.toggleChooseAll(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ...visibleProjects.map(
                        (p) => CheckboxListTile(
                          title: Text(p.name!),
                          value: projects!.contains(p),
                          onChanged: (_) => ctrl.toggleChosenProject(p),
                          contentPadding: EdgeInsets.only(right: 4),
                        ),
                      ),
                    ],
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
            child: ValueListenableBuilder<ApiResponse<List<Project>?>?>(
              valueListenable: ctrl.chosenProjects,
              builder: (_, projects, __) => projects?.data == null || projects!.data!.isEmpty
                  ? const SizedBox()
                  : LoadingButton(
                      onPressed: ctrl.goToHome,
                      text: 'Confirm',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
