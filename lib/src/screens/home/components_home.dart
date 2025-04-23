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

class _FeatureAddedBottomsheet extends StatelessWidget {
  const _FeatureAddedBottomsheet({required this.onConfirm, required this.onSkip});

  final VoidCallback onConfirm;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Image.asset(
          'assets/illustrations/notifications.png',
          height: 200,
        ),
        const SizedBox(
          height: 40,
        ),
        Text(
          "Don't miss a thing!",
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          '''
Want to stay in the loop? 
Turn on push notifications to catch all the important updates on your projects right when they happen.

You can switch them on or off anytime in Settings > Notifications.
''',
          style:
              context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.normal, fontFamily: AppTheme.defaultFont),
        ),
        const SizedBox(
          height: 52,
        ),
        LoadingButton(
          onPressed: onConfirm,
          text: 'Configure',
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
