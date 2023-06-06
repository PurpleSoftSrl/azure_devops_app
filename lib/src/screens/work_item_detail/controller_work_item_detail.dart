part of work_item_detail;

class _WorkItemDetailController with ShareMixin, FilterMixin {
  factory _WorkItemDetailController({
    required WorkItemDetailArgs args,
    required AzureApiService apiService,
    required StorageService storageService,
  }) {
    // handle page already in memory with a different work item
    if (_instances[args.hashCode] != null) {
      return _instances[args.hashCode]!;
    }

    if (instance != null && instance!.args != args) {
      instance = _WorkItemDetailController._(args, apiService, storageService);
    }

    instance ??= _WorkItemDetailController._(args, apiService, storageService);
    return _instances.putIfAbsent(args.hashCode, () => instance!);
  }

  _WorkItemDetailController._(this.args, this.apiService, this.storageService);

  static _WorkItemDetailController? instance;

  static final Map<int, _WorkItemDetailController> _instances = {};

  final WorkItemDetailArgs args;

  final AzureApiService apiService;

  final StorageService storageService;

  final itemDetail = ValueNotifier<ApiResponse<WorkItemWithUpdates?>?>(null);

  String get itemWebUrl => '${apiService.basePath}/${args.project}/_workitems/edit/${args.id}';

  List<WorkItemState> statuses = [];

  List<WorkItemUpdate> updates = [];
  final showUpdatesReversed = ValueNotifier<bool>(true);

  final isDownloadingAttachment = ValueNotifier<Map<int, bool>>({});

  void dispose() {
    instance = null;
    _instances.remove(args.hashCode);
  }

  Future<void> init() async {
    final res = await apiService.getWorkItemDetail(projectName: args.project, workItemId: args.id);

    itemDetail.value = res;
    updates = itemDetail.value?.data?.updates ?? [];
  }

  void toggleShowUpdatesReversed() {
    showUpdatesReversed.value = !showUpdatesReversed.value;
  }

  void shareWorkItem() {
    shareUrl(itemWebUrl);
  }

  void goToProject() {
    AppRouter.goToProjectDetail(args.project);
  }

  // ignore: long-method
  Future<void> editWorkItem() async {
    final fields = itemDetail.value!.data!.item.fields;

    final projectWorkItemTypes = apiService.workItemTypes[fields.systemTeamProject] ?? <WorkItemType>[];

    var newWorkItemStatus = apiService.workItemStates[fields.systemTeamProject]?[fields.systemWorkItemType]
        ?.firstWhereOrNull((s) => s.name == fields.systemState);

    var newWorkItemType = projectWorkItemTypes.firstWhereOrNull((t) => t.name == fields.systemWorkItemType) ??
        WorkItemType(
          name: fields.systemWorkItemType,
          referenceName: fields.systemWorkItemType,
          color: '',
          isDisabled: false,
          icon: '',
        );

    statuses = apiService.workItemStates[fields.systemTeamProject]?[newWorkItemType.name] ?? [];

    var newWorkItemAssignedTo =
        getSortedUsers(apiService).firstWhereOrNull((u) => u.mailAddress == fields.systemAssignedTo?.uniqueName) ??
            userAll;

    var newWorkItemTitle = fields.systemTitle;
    var newWorkItemDescription = fields.systemDescription ?? '';

    var shouldEdit = false;

    final titleFieldKey = GlobalKey<FormFieldState<dynamic>>();

    await OverlayService.bottomsheet(
      isScrollControlled: true,
      title: 'Edit work item',
      heightPercentage: .9,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      builder: (context) {
        final style = context.textTheme.bodySmall!.copyWith(height: 1, fontWeight: FontWeight.bold);
        return ListView(
          children: [
            StatefulBuilder(
              builder: (_, setState) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (newWorkItemStatus != null) ...[
                    Row(
                      children: [
                        Text(
                          'Status:',
                          style: style,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        FilterMenu<WorkItemState>(
                          title: 'Status',
                          values: statuses,
                          currentFilter: newWorkItemStatus!,
                          formatLabel: (t) => t.name,
                          onSelected: (f) {
                            setState(() => newWorkItemStatus = f);
                          },
                          isDefaultFilter: false,
                          widgetBuilder: (s) => WorkItemStateFilterWidget(state: s),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                  if (itemDetail.value!.data!.item.canBeChanged) ...[
                    Row(
                      children: [
                        Text(
                          'Type:',
                          style: style,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        FilterMenu<WorkItemType>(
                          title: 'Type',
                          values: projectWorkItemTypes,
                          currentFilter: newWorkItemType,
                          formatLabel: (t) => t.name,
                          onSelected: (f) async {
                            newWorkItemType = f;
                            statuses = apiService.workItemStates[fields.systemTeamProject]![newWorkItemType.name] ?? [];
                            if (!statuses.map((e) => e.name).contains(newWorkItemStatus)) {
                              // change status if new type doesn't support current status
                              newWorkItemStatus = statuses.firstOrNull ?? newWorkItemStatus;
                            }

                            setState(() => true);
                          },
                          isDefaultFilter: newWorkItemType == WorkItemType.all,
                          widgetBuilder: (t) => WorkItemTypeFilter(type: t),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                  Row(
                    children: [
                      Text(
                        'Assigned to:',
                        style: style,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      FilterMenu<GraphUser>(
                        title: 'Assigned to',
                        values: getSortedUsers(apiService, withUserAll: false),
                        currentFilter: newWorkItemAssignedTo,
                        onSelected: (u) {
                          setState(() => newWorkItemAssignedTo = u);
                        },
                        formatLabel: (u) => u.displayName!,
                        isDefaultFilter: newWorkItemAssignedTo.displayName == userAll.displayName,
                        widgetBuilder: (u) => UserFilterWidget(user: u),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            DevOpsFormField(
              initialValue: newWorkItemTitle,
              onChanged: (value) => newWorkItemTitle = value,
              label: 'Title',
              formFieldKey: titleFieldKey,
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(
              height: 20,
            ),
            DevOpsFormField(
              initialValue: newWorkItemDescription,
              onChanged: (value) => newWorkItemDescription = value,
              label: 'Description',
              maxLines: 3,
              onFieldSubmitted: AppRouter.popRoute,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(
              height: 60,
            ),
            LoadingButton(
              onPressed: () {
                if (titleFieldKey.currentState!.validate()) {
                  shouldEdit = true;
                  AppRouter.popRoute();
                }
              },
              text: 'Confirm',
            ),
            const SizedBox(
              height: 40,
            ),
          ],
        );
      },
    );

    if (!shouldEdit) return;

    if (newWorkItemType.name == fields.systemWorkItemType &&
        (newWorkItemStatus?.name ?? '') == fields.systemState &&
        newWorkItemTitle == fields.systemTitle &&
        newWorkItemAssignedTo.displayName == (fields.systemAssignedTo?.displayName ?? userAll.displayName) &&
        newWorkItemDescription == (fields.systemDescription ?? '')) {
      return;
    }

    final res = await apiService.editWorkItem(
      projectName: args.project,
      id: args.id,
      type: newWorkItemType,
      title: newWorkItemTitle,
      assignedTo: newWorkItemAssignedTo.displayName == userAll.displayName ? null : newWorkItemAssignedTo,
      description: newWorkItemDescription,
      status: newWorkItemStatus?.name,
    );

    if (res.isError) {
      return OverlayService.error('Error', description: 'Work item not edited');
    }

    await init();
  }

  Future<void> deleteWorkItem() async {
    final conf = await OverlayService.confirm('Attention', description: 'Do you really want to delete this work item?');
    if (!conf) return;

    final res = await apiService.deleteWorkItem(projectName: args.project, id: args.id);
    if (!(res.data ?? false)) {
      return OverlayService.error('Error', description: 'Work item not deleted');
    }

    AppRouter.pop();
  }

  Future<void> openAttachment(Relation attachment) async {
    final attributes = attachment.attributes;

    if (attributes?.id == null || attributes?.name == null) return;

    if (isDownloadingAttachment.value[attributes!.id] ?? false) return;

    final fileName = attributes.name!;

    final tmp = await getApplicationSupportDirectory();
    final filePath = path.join(tmp.path, '${attributes.id}_$fileName');

    // avoid downloading the same file multiple times
    if (await File(filePath).exists()) {
      await _openFile(filePath);
      return;
    }

    // deleted files cannot be downloaded anymore
    if (attachment.url == null) {
      OverlayService.snackbar('This file has been deleted', isError: true);
      return;
    }

    isDownloadingAttachment.value = {attributes.id!: true};

    final attachmentId = attachment.url!.split('/').last;
    final res = await apiService.getWorkItemAttachment(
      projectName: args.project,
      attachmentId: attachmentId,
      fileName: fileName,
    );
    if (res.isError) {
      isDownloadingAttachment.value = {};
      OverlayService.snackbar('Error downloading attachment', isError: true);
      return;
    }

    File(filePath).writeAsBytesSync(res.data!);

    isDownloadingAttachment.value = {};

    await _openFile(filePath);
  }

  Future<void> _openFile(String filePath) async {
    final open = await OpenFilex.open(filePath);
    switch (open.type) {
      case ResultType.done:
        break;
      case ResultType.noAppToOpen:
        await OverlayService.error('Error opening file', description: 'No app found to open this file');
        break;
      case ResultType.fileNotFound:
      case ResultType.permissionDenied:
      case ResultType.error:
        await OverlayService.error('Error opening file', description: 'Something went wrong');
        break;
    }
  }
}
