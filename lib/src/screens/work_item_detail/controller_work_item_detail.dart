part of work_item_detail;

class _WorkItemDetailController with ShareMixin, FilterMixin, AppLogger {
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

  List<ItemUpdate> updates = [];

  final showUpdatesReversed = ValueNotifier<bool>(true);

  final historyKey = GlobalKey();

  final isDownloadingAttachment = ValueNotifier<Map<int, bool>>({});

  final showCommentField = ValueNotifier<bool>(false);

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

  Future<void> editWorkItem() async {
    // wait for popup menu to close
    await Future<void>.delayed(Duration(milliseconds: 100));

    await AppRouter.goToCreateOrEditWorkItem(project: args.project, id: args.id);
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

    final hasConfirmed = await _showEditor(editorController, editorGlobalKey, title: 'Add comment');
    if (!hasConfirmed) return;

    final comment = await _getTextFromEditor(editorController);
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

    await init();
  }

  void onHistoryVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0 && !showCommentField.value) {
      showCommentField.value = true;
    } else if (instance != null && info.visibleFraction == 0 && showCommentField.value) {
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

    await init();
  }

  Future<void> editWorkItemComment(CommentItemUpdate update) async {
    final editorController = HtmlEditorController();
    final editorGlobalKey = GlobalKey<State>();

    final hasConfirmed = await _showEditor(
      editorController,
      editorGlobalKey,
      initialText: update.text,
      title: 'Edit comment',
    );
    if (!hasConfirmed) return;

    final comment = await _getTextFromEditor(editorController);
    if (comment == null) return;

    final res = await apiService.editWorkItemComment(projectName: args.project, update: update, text: comment);

    if (res.isError) {
      return OverlayService.error('Error', description: 'Comment not edited');
    }

    await init();
  }

  Future<bool> _showEditor(
    HtmlEditorController controller,
    GlobalKey<State<StatefulWidget>> globalKey, {
    String? initialText,
    required String title,
  }) async {
    var confirm = false;

    final hasChanged = ValueNotifier<bool>(false);

    await OverlayService.bottomsheet(
      heightPercentage: .9,
      isScrollControlled: true,
      title: title,
      topRight: ValueListenableBuilder<bool>(
        valueListenable: hasChanged,
        builder: (context, changed, __) => SizedBox(
          width: 80,
          height: 20,
          child: !changed
              ? Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: AppRouter.popRoute,
                    child: Icon(Icons.close),
                  ),
                )
              : TextButton(
                  onPressed: () {
                    confirm = true;
                    AppRouter.popRoute();
                  },
                  style: ButtonStyle(padding: MaterialStatePropertyAll(EdgeInsets.zero)),
                  child: Text(
                    'Confirm',
                    style: context.textTheme.bodyMedium!.copyWith(color: context.colorScheme.primary),
                  ),
                ),
        ),
      ),
      builder: (context) => ListView(
        children: [
          DevOpsHtmlEditor(
            autofocus: true,
            editorController: controller,
            editorGlobalKey: globalKey,
            onKeyUp: (_) {
              if (!hasChanged.value) hasChanged.value = true;
            },
            initialText: initialText,
          ),
          SizedBox(key: globalKey),
        ],
      ),
    );

    return confirm;
  }

  Future<String?> _getTextFromEditor(HtmlEditorController editorController) async {
    final comment = await editorController.getText();

    if (comment.trim().isEmpty) return null;

    final trimmed = comment.trim().replaceAll(' ', '');
    if (trimmed == '<br>' || trimmed == '<div><br></div>') return null;

    return comment;
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

    OverlayService.snackbar('Attachment successfully added');
    await init();
  }
}
