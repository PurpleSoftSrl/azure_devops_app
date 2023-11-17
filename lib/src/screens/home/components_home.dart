part of home;

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.parameters,
    required this.project,
    required this.onTap,
  });

  final _HomeParameters parameters;
  final Project project;
  final void Function(Project p) onTap;

  @override
  Widget build(BuildContext context) {
    final apiService = AzureApiServiceInherited.of(context).apiService;
    return SizedBox(
      height: parameters.projectCardHeight,
      child: NavigationButton(
        margin: const EdgeInsets.only(top: 8),
        inkwellKey: ValueKey(project.name),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        onTap: () => onTap(project),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: apiService.isImageUnauthorized
                  ? SizedBox(
                      height: 30,
                      width: 30,
                      child: Icon(DevOpsIcons.project),
                    )
                  : CachedNetworkImage(
                      imageUrl: project.defaultTeamImageUrl!,
                      httpHeaders: apiService.headers,
                      errorWidget: (_, __, ___) => Icon(DevOpsIcons.project),
                      width: 30,
                      height: 30,
                    ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(child: Text(project.name!)),
            Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}

class _ProjectsHeaderWithSearchField extends StatelessWidget {
  const _ProjectsHeaderWithSearchField({required this.ctrl});

  final _HomeController ctrl;

  @override
  Widget build(BuildContext context) {
    // TODO extract component. Duplicate code in work items search field
    return ValueListenableBuilder(
      valueListenable: ctrl.isSearchingProjects,
      builder: (context, isSearching, __) => SizedBox(
        height: 70,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
          reverseDuration: Duration(milliseconds: 250),
          child: isSearching
              ? Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: DevOpsFormField(
                    autofocus: true,
                    onChanged: ctrl.searchProjects,
                    hint: 'Search by name',
                    maxLines: 1,
                    suffix: GestureDetector(
                      onTap: ctrl.resetSearch,
                      child: Icon(
                        Icons.close,
                        color: context.colorScheme.onBackground,
                      ),
                    ),
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: SectionHeader.withIcon(
                        text: 'Projects',
                        icon: DevOpsIcons.list,
                        textHeight: 1,
                      ),
                    ),
                    IconButton(
                      onPressed: ctrl.showSearchField,
                      icon: Icon(
                        Icons.search,
                        size: 24,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
