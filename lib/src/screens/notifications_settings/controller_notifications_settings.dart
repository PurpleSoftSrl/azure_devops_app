part of notifications_settings;

class _NotificationsSettingsController with ApiErrorHelper {
  _NotificationsSettingsController._(this.api, this.storage);

  final AzureApiService api;
  final StorageService storage;

  final subscriptions = ValueNotifier<ApiResponse<List<HookSubscription>>?>(null);
  List<Project> projects = <Project>[];

  /// Map of project_eventType to list of entities which user can subscribe to
  /// (e.g. pipelines, repositories, branches, etc.)
  final _subscriptionChildren = <String, List<String>>{};

  String _userId = '';

  Future<void> init() async {
    projects = storage.getChosenProjects().toList();

    final res = await api.getSubscriptions();
    if (res.isError) return;

    for (final project in projects) {
      final projectSubscriptions = res.data?.where((s) => s.publisherInputs.projectId == project.id).toList() ?? [];
      for (final subscription in projectSubscriptions) {
        await _getSubscriptionChildren(project.id!, subscription.eventType);
      }
    }

    subscriptions.value = res;

    final userRes = await api.getUserToMention(email: api.user!.emailAddress!);
    _userId = userRes.data ?? '';

    if (_userId.isEmpty) _userIdError();
  }

  bool hasHookSubscription(String projectId, EventType type) {
    final subscription = _getSubscriptionByType(projectId, type);
    return subscription != null;
  }

  Future<void> createHookSubscription(String projectId, EventType type) async {
    if (hasHookSubscription(projectId, type)) return;

    PublisherInputs? publisherInputs;

    switch (type) {
      case EventType.buildCompleted:
        publisherInputs = PublisherInputs(projectId: projectId);
      case EventType.pullRequestMerged:
        publisherInputs = PublisherInputs(projectId: projectId, mergeResult: 'Succeeded');
      case EventType.pullRequestUpdated:
        publisherInputs = PublisherInputs(projectId: projectId);
      case EventType.workItemUpdated:
        publisherInputs = PublisherInputs(projectId: projectId);
      case EventType.approvalPending:
      case EventType.approvalCompleted:
        publisherInputs = PublisherInputs(projectId: projectId);
      case EventType.unknown:
    }

    if (publisherInputs == null) {
      return OverlayService.error('Error', description: 'Event type $type is not supported');
    }

    final res = await api.createHookSubscription(
      projectId: projectId,
      publisherId: type.publisherId,
      eventType: type,
      publisherInputs: publisherInputs,
    );

    if (res.isError) {
      final error = getErrorMessage(res.errorResponse!);
      return OverlayService.error('Error', description: error);
    }

    await _getSubscriptionChildren(projectId, type);

    await init();
  }

  Future<void> _getSubscriptionChildren(String projectId, EventType type) async {
    final key = '${projectId}_${type.value}';

    if (_subscriptionChildren.containsKey(key)) return;

    switch (type) {
      case EventType.buildCompleted:
      case EventType.approvalPending:
      case EventType.approvalCompleted:
        final res = await api.getPipelineDefinitions(projectId: projectId);
        _subscriptionChildren[key] = res.data ?? [];
      case EventType.pullRequestUpdated:
      case EventType.pullRequestMerged:
        final res = await api.getProjectRepositories(projectName: projectId);
        _subscriptionChildren[key] = res.data?.map((repo) => repo.name ?? '').toList() ?? [];
      case EventType.workItemUpdated:
        final res = await api.getWorkItemAreas(projectId: projectId);
        _subscriptionChildren[key] = res.data?.map((area) => area.escapedAreaPath).toList() ?? [];
      case EventType.unknown:
        _subscriptionChildren[key] = [];
    }
  }

  void togglePushNotifications(String projectId, EventType type, String child, {required bool value}) {
    if (!hasHookSubscription(projectId, type)) return;

    final subscription = _getSubscriptionByType(projectId, type);
    if (subscription == null) return;

    if (_userId.isEmpty) return _userIdError();

    final cleanChild = child.replaceAll(' ', '');

    final topic = switch (type) {
      EventType.buildCompleted ||
      EventType.pullRequestMerged ||
      EventType.pullRequestUpdated ||
      EventType.workItemUpdated ||
      EventType.approvalPending ||
      EventType.approvalCompleted =>
        'topic_${subscription.id}_${cleanChild}_$_userId',
      EventType.unknown => '',
    };

    if (topic.isEmpty) {
      OverlayService.error('Error', description: 'Event type $type is not supported');
      return;
    }

    if (value) {
      NotificationsService().subscribeToTopic(topic);
    } else {
      NotificationsService().unsubscribeFromTopic(topic);
    }

    storage.setSubscriptionStatus(subscription, cleanChild, isSubscribed: value);

    _refreshUI();
  }

  bool isPushNotificationsEnabled(String projectId, EventType type, String child) {
    final cleanChild = child.replaceAll(' ', '');

    final sub = _getSubscriptionByType(projectId, type);
    return sub != null && storage.isSubscribedTo(sub, cleanChild);
  }

  HookSubscription? _getSubscriptionByType(String projectId, EventType type) {
    final subscription = subscriptions.value?.data
        ?.firstWhereOrNull((s) => s.publisherInputs.projectId == projectId && s.eventType == type);
    return subscription;
  }

  void _refreshUI() {
    subscriptions.value = ApiResponse.ok([...subscriptions.value?.data ?? []]);
  }

  void _userIdError() {
    OverlayService.snackbar(
      'Error retrieving user ID, subscription to push notifications will not work',
      isError: true,
    );
  }
}
