part of home;

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({
    required this.shortcut,
    required this.onTap,
    required this.onShowDetail,
    required this.onRename,
    required this.onDelete,
  });

  final SavedShortcut shortcut;
  final void Function(SavedShortcut) onTap;
  final void Function(SavedShortcut) onShowDetail;
  final void Function(SavedShortcut) onRename;
  final void Function(SavedShortcut) onDelete;

  @override
  Widget build(BuildContext context) {
    return NavigationButton(
      margin: const EdgeInsets.only(top: 8),
      inkwellKey: ValueKey(shortcut.label),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      onTap: () => onTap(shortcut),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                switch (shortcut.area) {
                  FilterAreas.commits => DevOpsIcons.commit,
                  FilterAreas.pipelines => DevOpsIcons.pipeline,
                  FilterAreas.workItems => DevOpsIcons.task,
                  FilterAreas.pullRequests => DevOpsIcons.pullrequest,
                  _ => DevOpsIcons.task,
                },
                color: context.colorScheme.onPrimary,
                size: 14,
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shortcut.label,
                  style: context.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  shortcut.area,
                  style: context.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          DevOpsPopupMenu(
            tooltip: 'Shortcut ${shortcut.label} actions',
            offset: const Offset(0, 20),
            items: () => [
              PopupItem(
                onTap: () => onShowDetail(shortcut),
                text: 'Show filters',
                icon: DevOpsIcons.filter,
              ),
              PopupItem(
                onTap: () => onRename(shortcut),
                text: 'Rename',
                icon: DevOpsIcons.edit,
              ),
              PopupItem(
                onTap: () => onDelete(shortcut),
                text: 'Delete',
                icon: DevOpsIcons.trash,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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

class _SubscriptionAddedBottomsheet extends StatelessWidget {
  const _SubscriptionAddedBottomsheet({required this.onRemoveAds, required this.onSkip});

  final VoidCallback onRemoveAds;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Image.asset(
          'assets/illustrations/crying_smiling_guy.png',
          height: 200,
        ),
        const SizedBox(
          height: 40,
        ),
        Text(
          '''
In this release, we've introduced ads to help support the app's ongoing development and keep things running smoothly.

We understand that ads can be disruptive, so we've also added an option for you to remove them with a paid subscription.

Would you like to remove them?
''',
          style: context.textTheme.bodyLarge,
        ),
        const SizedBox(
          height: 52,
        ),
        LoadingButton(
          onPressed: onRemoveAds,
          text: 'Remove ads',
        ),
        const SizedBox(
          height: 16,
        ),
        TextButton(
          onPressed: onSkip,
          child: Text('Later'),
        ),
        const SizedBox(
          height: 48,
        ),
      ],
    );
  }
}
