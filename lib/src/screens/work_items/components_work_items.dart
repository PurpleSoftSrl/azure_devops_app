part of work_items;

class _Actions extends StatelessWidget {
  const _Actions({required this.ctrl});

  final _WorkItemsController ctrl;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: DevOpsAnimatedSearchField(
        isSearching: ctrl.isSearching,
        onChanged: ctrl._searchWorkItem,
        onResetSearch: ctrl.resetSearch,
        hint: 'Search by id or title',
        margin: const EdgeInsets.only(left: 56, right: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SearchButton(
              isSearching: ctrl.isSearching,
            ),
            IconButton(
              onPressed: ctrl.createWorkItem,
              icon: Icon(
                DevOpsIcons.plus,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
