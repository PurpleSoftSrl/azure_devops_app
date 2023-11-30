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
    return DevOpsAnimatedSearchField(
      isSearching: ctrl.isSearchingProjects,
      onChanged: ctrl.searchProjects,
      onResetSearch: ctrl.resetSearch,
      hint: 'Search by name',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: SectionHeader.withIcon(
              text: 'Projects',
              icon: DevOpsIcons.list,
              textHeight: 1,
            ),
          ),
          SearchButton(
            isSearching: ctrl.isSearchingProjects,
          ),
        ],
      ),
    );
  }
}
