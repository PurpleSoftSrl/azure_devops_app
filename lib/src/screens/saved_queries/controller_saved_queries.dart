part of saved_queries;

class _SavedQueriesController {
  _SavedQueriesController._(this.args, this.api, this.ads);

  final SavedQueriesArgs? args;
  final AzureApiService api;
  final AdsService ads;

  final savedQueries = ValueNotifier<ApiResponse<SavedQuery>?>(null);

  Future<void> init() async {
    final res = await api.getProjectSavedQuery(projectName: args!.project!, queryId: args!.queryId!);
    savedQueries.value = res;
  }

  void goToQuery(ChildQuery query) {
    if (!query.isFolder) {
      if (query.queryType != 'flat') {
        return OverlayService.snackbar('Only flat list queries are supported', isError: true);
      }

      AppRouter.goToWorkItems(args: (project: null, shortcut: null, savedQuery: query));
      return;
    }

    AppRouter.goToSavedQueries(args: (project: args!.project, path: query.path, queryId: query.id));
  }

  Future<void> renameQuery(ChildQuery query) async {
    final queryName = await OverlayService.formBottomsheet(
      title: 'Rename query',
      label: 'Name',
      initialValue: query.name,
    );
    if (queryName == null) return;

    final res = await api.renameSavedQuery(projectName: args!.project!, queryId: query.id, name: queryName);

    if (res.isError) {
      return OverlayService.error('Error', description: 'Query not renamed');
    }

    await _showInterstitialAd(
      onDismiss: () => OverlayService.snackbar('Query successfully renamed'),
    );

    await init();
  }

  Future<void> deleteQuery(ChildQuery query) async {
    final confirm = await OverlayService.confirm(
      'Attention',
      description: 'Do you really want to delete this query?',
    );
    if (!confirm) return;

    final res = await api.deleteSavedQuery(projectName: args!.project!, queryId: query.id);

    if (res.isError) {
      return OverlayService.error('Error', description: 'Query not deleted');
    }

    await _showInterstitialAd(
      onDismiss: () => OverlayService.snackbar('Query successfully deleted'),
    );

    await init();
  }

  Future<void> _showInterstitialAd({VoidCallback? onDismiss}) async {
    await ads.showInterstitialAd(onDismiss: onDismiss);
  }
}
