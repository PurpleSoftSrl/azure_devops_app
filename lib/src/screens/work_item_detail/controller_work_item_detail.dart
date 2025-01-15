part of work_item_detail;

class _WorkItemDetailController with ShareMixin, FilterMixin, AppLogger {
  _WorkItemDetailController._(this.args, this.apiService, this.storageService, this.ads);

  final WorkItemDetailArgs args;
  final AzureApiService apiService;
  final StorageService storageService;
  final AdsService ads;

  final itemDetail = ValueNotifier<ApiResponse<WorkItemWithUpdates?>?>(null);

  String get itemWebUrl => '${apiService.basePath}/${args.project}/_workitems/edit/${args.id}';

  List<WorkItemState> statuses = [];

  List<ItemUpdate> updates = [];

  final showUpdatesReversed = ValueNotifier<bool>(true);

  final historyKey = GlobalKey();

  final isDownloadingAttachment = ValueNotifier<Map<int, bool>>({});

  final showCommentField = ValueNotifier<bool>(false);

  Map<String, Set<WorkItemField>> fieldsToShow = {};

  var _isDisposed = false;

  Future<void> init() async {
    final res = await apiService.getWorkItemDetail(projectName: args.project, workItemId: args.id);

    if (!res.isError) {
      final fieldsRes = await apiService.getWorkItemTypeFields(
        projectName: args.project,
        workItemName: res.data!.item.fields.systemWorkItemType,
      );

      fieldsToShow = fieldsRes.data?.fields ?? <String, Set<WorkItemField>>{};
    }

    itemDetail.value = res;
    updates = itemDetail.value?.data?.updates ?? [];
  }

  void dispose() {
    _isDisposed = true;
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

  Future<void> editWorkItem() async {
    // wait for popup menu to close
    await Future<void>.delayed(Duration(milliseconds: 100));

    await AppRouter.goToCreateOrEditWorkItem(
      args: (
        project: args.project,
        id: args.id,
        area: null,
        iteration: null,
      ),
    );

    await init();
  }

  Future<void> deleteWorkItem() async {
    final conf = await OverlayService.confirm('Attention', description: 'Do you really want to delete this work item?');
    if (!conf) return;

    final type = itemDetail.value!.data!.item.fields.systemWorkItemType;
    final res = await apiService.deleteWorkItem(projectName: args.project, id: args.id, type: type);
    if (!(res.data ?? false)) {
      return OverlayService.error('Error', description: 'Work item not deleted');
    }

    await _showInterstitialAd();

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
      case ResultType.fileNotFound:
      case ResultType.permissionDenied:
      case ResultType.error:
        await OverlayService.error('Error opening file', description: 'Something went wrong');
    }
  }

  Future<void> addComment() async {
    final editorController = HtmlEditorController();
    final editorGlobalKey = GlobalKey<State>();

    final hasConfirmed = await showEditor(editorController, editorGlobalKey, title: 'Add comment');
    if (!hasConfirmed) return;

    final comment = await getTextFromEditor(editorController);
    if (comment == null) return;

    final res = await apiService.addWorkItemComment(
      projectName: args.project,
      id: args.id,
      text: comment,
    );

    logAnalytics('add_work_item_comment', {
      'work_item_type': itemDetail.value?.data?.item.fields.systemWorkItemType ?? 'unknown type',
      'comment_length': comment.length,
      'is_error': res.isError.toString(),
    });

    if (res.isError) {
      return OverlayService.error('Error', description: 'Comment not added');
    }

    await _showInterstitialAd();

    await init();
  }

  void onHistoryVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0 && !showCommentField.value) {
      showCommentField.value = true;
    } else if (!_isDisposed && info.visibleFraction == 0 && showCommentField.value) {
      showCommentField.value = false;
    }
  }

  Future<void> deleteWorkItemComment(CommentItemUpdate update) async {
    final confirm = await OverlayService.confirm(
      'Attention',
      description: 'Do you really want to delete this comment?',
    );
    if (!confirm) return;

    final res = await apiService.deleteWorkItemComment(projectName: args.project, update: update);

    if (res.isError) {
      return OverlayService.error('Error', description: 'Comment not deleted');
    }

    await _showInterstitialAd();

    await init();
  }

  Future<void> editWorkItemComment(CommentItemUpdate update) async {
    final editorController = HtmlEditorController();
    final editorGlobalKey = GlobalKey<State>();

    final hasConfirmed = await showEditor(
      editorController,
      editorGlobalKey,
      initialText: update.text,
      title: 'Edit comment',
    );
    if (!hasConfirmed) return;

    final comment = await getTextFromEditor(editorController);
    if (comment == null) return;

    final res = await apiService.editWorkItemComment(projectName: args.project, update: update, text: comment);

    if (res.isError) {
      return OverlayService.error('Error', description: 'Comment not edited');
    }

    await _showInterstitialAd();

    await init();
  }

  Future<void> addAttachment() async {
    final result = await FilePicker.platform.pickFiles();
    if ((result?.files ?? []).isEmpty) return;

    final file = File(result!.files.single.path!);

    final res = await apiService.addWorkItemAttachment(
      projectName: args.project,
      fileName: file.path.split('/').last,
      filePath: file.path,
      workItemId: args.id,
    );
    if (res.isError) {
      return OverlayService.error('Error', description: 'Attachment not added');
    }

    await _showInterstitialAd(
      onDismiss: () => OverlayService.snackbar('Attachment successfully added'),
    );

    await init();
  }

  /// Returns true if there are some fields in the given group and there is at least
  /// one field set by the user in this group.
  bool shouldShowGroupLabel({required String group}) {
    final fields = fieldsToShow[group] ?? {};
    if (fields.isEmpty) return false;

    final jsonFields = itemDetail.value!.data!.item.fields.jsonFields;
    return fields.any(
      (f) => jsonFields[f.referenceName] != null && jsonFields[f.referenceName]!.toString().isNotEmpty,
    );
  }

  void openLinkedWorkItem(String id, Relation relation) {
    final url = relation.url;
    if (url == null) return;

    final project = url.substring(0, url.indexOf('/_apis')).split('/').lastOrNull;
    if (project == null) return;

    final parsedId = int.tryParse(id);
    if (parsedId == null) return;

    AppRouter.goToWorkItemDetail(project: project, id: parsedId);
  }

  void goToWorkItemDetail(Relation link) {
    final url = link.url ?? '';
    if (url.isEmpty) return;

    final projectId = link.linkedWorkItemProjectId;
    final id = link.linkedWorkItemId;

    if (projectId.isEmpty || id <= 0) return;

    AppRouter.goToWorkItemDetail(project: projectId, id: id);
  }

  Future<void> _showInterstitialAd({VoidCallback? onDismiss}) async {
    await ads.showInterstitialAd(onDismiss: onDismiss);
  }
}
