part of saved_queries;

class _SavedQueriesController {
  _SavedQueriesController._(this.args, this.api);

  final SavedQueriesArgs? args;
  final AzureApiService api;

  final savedQueries = ValueNotifier<ApiResponse<SavedQuery>?>(null);

  Future<void> init() async {
    final res = await api.getProjectSavedQuery(projectName: args!.project!, queryId: args!.queryId!);
    savedQueries.value = res;
  }

  void goToQuery(ChildQuery query) {
    if (!query.isFolder) {
      AppRouter.goToWorkItems(args: (project: null, shortcut: null, savedQuery: query));
      return;
    }

    AppRouter.goToSavedQueries(args: (project: args!.project, path: query.path, queryId: query.id));
  }
}
