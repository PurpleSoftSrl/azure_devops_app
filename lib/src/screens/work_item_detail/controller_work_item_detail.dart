part of work_item_detail;

typedef _MentionGuidWithName = ({String guid, String name});

class _WorkItemDetailController with ShareMixin, FilterMixin, AppLogger, AdsMixin {
  _WorkItemDetailController._(this.args, this.api, this.storage, this.ads);

  final WorkItemDetailArgs args;
  final AzureApiService api;
  final StorageService storage;
  final AdsService ads;

  final itemDetail = ValueNotifier<ApiResponse<WorkItemWithUpdates?>?>(null);

  String get itemWebUrl => '${api.basePath}/${args.project}/_workitems/edit/${args.id}';

  List<WorkItemState> statuses = [];

  List<ItemUpdate> updates = [];

  final showUpdatesReversed = ValueNotifier<bool>(true);

  final historyKey = GlobalKey();

  final isDownloadingAttachment = ValueNotifier<Map<int, bool>>({});

  final showCommentField = ValueNotifier<bool>(false);

  Map<String, Set<WorkItemField>> fieldsToShow = {};

  final _mentionRegExp = RegExp('@<[a-zA-Z0-9-]+>');

  var _isDisposed = false;

  Future<void> init() async {
    final res = await api.getWorkItemDetail(projectName: args.project, workItemId: args.id);

    if (!res.isError) {
      final fieldsRes = await api.getWorkItemTypeFields(
        projectName: args.project,
        workItemName: res.data!.item.fields.systemWorkItemType,
      );

      fieldsToShow = fieldsRes.data?.fields ?? <String, Set<WorkItemField>>{};
    }

    updates = res.data?.updates ?? [];

    for (final update in updates.whereType<CommentItemUpdate>()) {
      update.text = await _getReplacedComment(update.text);
    }

    itemDetail.value = res;
  }

  void dispose() {
    _isDisposed = true;
  }

  Future<String> _getReplacedComment(String text) async {
    final mentionGuids = _getMentionGuids(text);

    final mentionsWithNames = await _getIdentitiesFromGuids(mentionGuids.toSet());

    var replacedText = text;

    for (final mention in mentionsWithNames) {
      replacedText = replacedText.replaceAll(
        RegExp('@<${mention.guid}>', caseSensitive: false),
        '[${mention.name}](@${mention.guid})',
      );
    }

    return replacedText;
  }

  List<String> _getMentionGuids(String text) {
    final allMatches = _mentionRegExp.allMatches(text);
    if (allMatches.isEmpty) return [];

    final res = <String>[];

    for (final match in allMatches) {
      res.add(text.substring(match.start + 2, match.end - 1).trim());
    }

    return res;
  }

  Future<List<_MentionGuidWithName>> _getIdentitiesFromGuids(Set<String> mentionsToReplace) async {
    final res = await Future.wait([for (final mention in mentionsToReplace) api.getIdentityFromGuid(guid: mention)]);

    final identitites = res.where((r) => !r.isError && r.data != null).map((r) => r.data!);
    return identitites.map((i) => (guid: i.guid ?? '', name: i.displayName)).toList();
  }

  void toggleShowUpdatesReversed() {
    showUpdatesReversed.value = !showUpdatesReversed.value;
  }

  void shareWorkItem() {
    shareUrl(itemWebUrl);
  }

  void goToProject() {
    AppRouter.goToProjectDetail(itemDetail.value!.data!.item.fields.systemTeamProject);
  }

  Future<void> editWorkItem() async {
    // wait for popup menu to close
    await Future<void>.delayed(Duration(milliseconds: 100));

    final editItemArgs = CreateOrEditWorkItemArgs(project: args.project, id: args.id);
    await AppRouter.goToCreateOrEditWorkItem(args: editItemArgs);

    await init();
  }

  Future<void> deleteWorkItem() async {
    final conf = await OverlayService.confirm('Attention', description: 'Do you really want to delete this work item?');
    if (!conf) return;

    final type = itemDetail.value!.data!.item.fields.systemWorkItemType;
    final res = await api.deleteWorkItem(projectName: args.project, id: args.id, type: type);
    if (!(res.data ?? false)) {
      return OverlayService.error('Error', description: 'Work item not deleted');
    }

    await showInterstitialAd(ads, onDismiss: () => OverlayService.snackbar('Work item successfully deleted'));

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
    final res = await api.getWorkItemAttachment(
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
    final open = await OpenFile.open(filePath);
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

    final res = await api.addWorkItemComment(projectName: args.project, id: args.id, text: comment);

    logAnalytics('add_work_item_comment', {
      'work_item_type': itemDetail.value?.data?.item.fields.systemWorkItemType ?? 'unknown type',
      'comment_length': comment.length,
      'is_error': res.isError.toString(),
    });

    if (res.isError) {
      return OverlayService.error('Error', description: 'Comment not added');
    }

    await showInterstitialAd(ads);

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

    final res = await api.deleteWorkItemComment(projectName: args.project, update: update);

    if (res.isError) {
      return OverlayService.error('Error', description: 'Comment not deleted');
    }

    await showInterstitialAd(ads);

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

    final res = await api.editWorkItemComment(projectName: args.project, update: update, text: comment);

    if (res.isError) {
      return OverlayService.error('Error', description: 'Comment not edited');
    }

    await showInterstitialAd(ads);

    await init();
  }

  Future<void> addAttachment() async {
    final result = await FilePicker.platform.pickFiles();
    if ((result?.files ?? []).isEmpty) return;

    final file = File(result!.files.single.path!);

    final res = await api.addWorkItemAttachment(
      projectName: args.project,
      fileName: file.path.split('/').last,
      filePath: file.path,
      workItemId: args.id,
    );
    if (res.isError) {
      return OverlayService.error('Error', description: 'Attachment not added');
    }

    await showInterstitialAd(ads, onDismiss: () => OverlayService.snackbar('Attachment successfully added'));

    await init();
  }

  /// Returns true if there are some fields in the given group and there is at least
  /// one field set by the user in this group.
  bool shouldShowGroupLabel({required String group}) {
    final fields = fieldsToShow[group] ?? {};
    if (fields.isEmpty) return false;

    final jsonFields = itemDetail.value!.data!.item.fields.jsonFields;
    return fields.any((f) => jsonFields[f.referenceName] != null && jsonFields[f.referenceName]!.toString().isNotEmpty);
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

  String getReplacedText(String text) {
    return text.splitMapJoin(
      RegExp('![0-9]+'),
      onMatch: (p0) {
        final item = p0.group(0);
        if (item == null) return p0.input;

        final prId = item.substring(1);
        return '[!$prId](${api.basePath}/${args.project}/_apis/git/pullrequests/$prId)';
      },
    );
  }

  Future<void> onTapMarkdownLink(String text, String? href, String? _) async {
    if (href == null) return;

    final isPrLink = text.startsWith(RegExp('![0-9]+'));
    if (isPrLink) {
      final id = href.split('/').last;
      final parsedId = int.tryParse(id);
      if (parsedId == null) return;

      unawaited(AppRouter.goToPullRequestDetail(project: args.project, id: parsedId, repository: ''));
      return;
    }

    if (href.startsWith('@')) {
      final name = text;
      final user = await api.getUserFromDisplayName(name: name);
      if (user.isError) return;

      unawaited(AppRouter.goToMemberDetail(user.data!.descriptor!));
      return;
    }

    if (await canLaunchUrlString(href)) await launchUrlString(href);
  }
}
