part of repository_detail;

class _RepositoryDetailScreen extends StatelessWidget {
  const _RepositoryDetailScreen(this.ctrl, this.parameters);

  final _RepositoryDetailController ctrl;
  final _RepositoryDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage<List<RepoItem>?>(
      init: ctrl.init,
      title: (ctrl.args.filePath?.startsWith('/') ?? false ? ctrl.args.filePath?.substring(1) : ctrl.args.filePath) ??
          ctrl.args.repositoryName,
      notifier: ctrl.repoItems,
      onEmpty: 'No items found',
      builder: (items) {
        final pathPrefix = ctrl.args.filePath != null ? '${ctrl.args.filePath}' : '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (items!.isNotEmpty && items.first.path == '/') _BranchRow(ctrl: ctrl),
            ...items
                .where((i) => i.isFolder && i.path != pathPrefix && i.path != '/')
                .sorted((a, b) => a.path.compareTo(b.path))
                .where((i) => i.isFolder)
                .followedBy(
                  items.where((i) => !i.isFolder).sorted((a, b) => a.path.compareTo(b.path)),
                )
                .map(
                  (i) => InkWell(
                    onTap: () => ctrl.goToItem(i),
                    child: NavigationButton(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      backgroundColor: i.isFolder ? null : Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              i.path.replaceFirst('$pathPrefix/', ''),
                              style: context.textTheme.titleSmall!.copyWith(
                                decoration: i.isFolder ? null : TextDecoration.underline,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}
