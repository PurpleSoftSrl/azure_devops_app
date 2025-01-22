part of saved_queries;

class _SavedQueriesScreen extends StatelessWidget {
  const _SavedQueriesScreen(this.ctrl, this.parameters);

  final _SavedQueriesController ctrl;
  final _SavedQueriesParameters parameters;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      init: ctrl.init,
      title: ctrl.args!.path ?? 'Saved Queries',
      notifier: ctrl.savedQueries,
      builder: (query) => switch (query) {
        _ when query.isFolder && query.children.isEmpty => SizedBox(
            height: 600,
            child: const Center(child: Text('This folder is empty')),
          ),
        _ => Column(
            children: query.children
                .sortedBy((q) => q.path)
                .map(
                  (q) => InkWell(
                    onTap: () => ctrl.goToQuery(q),
                    child: NavigationButton(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      backgroundColor: q.isFolder ? null : Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              q.path.replaceFirst('${ctrl.args!.path}/', ''),
                              style: context.textTheme.titleSmall!.copyWith(
                                decoration: q.isFolder ? null : TextDecoration.underline,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      },
    );
  }
}
