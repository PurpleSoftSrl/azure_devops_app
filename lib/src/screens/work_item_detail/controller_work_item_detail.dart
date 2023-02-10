part of work_item_detail;

class _WorkItemDetailController {
  factory _WorkItemDetailController({required WorkItem item, required AzureApiService apiService}) {
    // handle page already in memory with a different work item
    if (_instances[item.hashCode] != null) {
      return _instances[item.hashCode]!;
    }

    if (instance != null && instance!.item != item) {
      instance = _WorkItemDetailController._(item, apiService, forceRefresh: true);
    }

    instance ??= _WorkItemDetailController._(item, apiService);
    return _instances.putIfAbsent(item.hashCode, () => instance!);
  }

  _WorkItemDetailController._(this.item, this.apiService, {bool forceRefresh = false}) {
    if (forceRefresh) init();
  }

  static _WorkItemDetailController? instance;

  static final Map<int, _WorkItemDetailController> _instances = {};

  final WorkItem item;

  final AzureApiService apiService;

  final itemDetail = ValueNotifier<ApiResponse<WorkItemDetail?>?>(null);

  String get itemWebUrl => '${apiService.basePath}/${item.teamProject}/_workitems/edit/${item.id}';

  void dispose() {
    instance = null;
    _instances.remove(item.hashCode);
  }

  Future<void> init() async {
    final res = await apiService.getWorkItemDetail(projectName: item.teamProject, workItemId: item.id);
    itemDetail.value = res;
  }

  void shareWorkItem() {
    Share.share(itemWebUrl);
  }

  void goToProject() {
    AppRouter.goToProjectDetail(item.teamProject);
  }
}
