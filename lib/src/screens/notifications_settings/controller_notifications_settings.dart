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

  final eventCategories = groupBy(EventType.values.where((t) => t != EventType.unknown), (e) => e.category);

  Future<void> init() async {
    projects = storage.getChosenProjects().toList();

    final res = await api.getSubscriptions();
    if (res.isError) return;

    for (final project in projects) {
      final projectSubscriptions = res.data?.where((s) => s.publisherInputs.projectId == project.id).toList() ?? [];
      for (final subscription in projectSubscriptions) {
        await _getSubscriptionChildren(project.id!, subscription.eventType.category);
      }
    }

    subscriptions.value = res;

    final userRes = await api.getUserToMention(email: api.user!.emailAddress!);
    _userId = userRes.data ?? '';

    if (_userId.isEmpty) _userIdError();
  }

  bool hasHookSubscription(String projectId, EventCategory category) {
    final subscription = _getSubscriptionsByCategory(projectId, category);
    return subscription.isNotEmpty;
  }

  Future<void> createHookSubscription(String projectId, EventCategory category) async {
    if (hasHookSubscription(projectId, category)) return;

    for (final type in category.eventTypes) {
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
    }

    await _getSubscriptionChildren(projectId, category);

    await init();
  }

  Future<void> _getSubscriptionChildren(String projectId, EventCategory category) async {
    final key = '${projectId}_${category.name}';

    if (_subscriptionChildren.containsKey(key)) return;

    switch (category) {
      case EventCategory.pipelines:
        final res = await api.getPipelineDefinitions(projectId: projectId);
        _subscriptionChildren[key] = res.data ?? [];
      case EventCategory.pullRequests:
        final res = await api.getProjectRepositories(projectName: projectId);
        _subscriptionChildren[key] = res.data?.map((repo) => repo.name ?? '').toList() ?? [];
      case EventCategory.workItems:
        final res = await api.getWorkItemAreas(projectId: projectId);
        _subscriptionChildren[key] = res.data?.map((area) => area.escapedAreaPath).toList() ?? [];
      case EventCategory.unknown:
        _subscriptionChildren[key] = [];
    }
  }

  List<String> getCachedSubscriptionChildren(String projectId, MapEntry<EventCategory, List<EventType>> entry) =>
      _subscriptionChildren['${projectId}_${entry.key.name}'] ?? <String>[];

  void togglePushNotifications(String projectId, EventCategory category, String child, {required bool value}) {
    if (!hasHookSubscription(projectId, category)) return;

    final subscriptions = _getSubscriptionsByCategory(projectId, category);
    if (subscriptions.isEmpty) return;

    if (_userId.isEmpty) return _userIdError();

    final cleanChild = child.replaceAll(' ', '');

    for (final subscription in subscriptions) {
      final topic = switch (category) {
        EventCategory.pipelines || EventCategory.pullRequests => 'topic_${subscription.id}_${cleanChild}_$_userId',
        // We use email address for work item updates because the user ID is not available in the devops webhook
        EventCategory.workItems =>
          'topic_${subscription.id}_${cleanChild}_${api.user!.emailAddress!.replaceAll('@', '.')}',
        EventCategory.unknown => '',
      };

      if (topic.isEmpty) {
        OverlayService.error('Error', description: 'Event category $category is not supported');
        return;
      }

      if (value) {
        NotificationsService().subscribeToTopic(topic);
      } else {
        NotificationsService().unsubscribeFromTopic(topic);
      }

      storage.setSubscriptionStatus(subscription, cleanChild, isSubscribed: value);
    }

    _refreshUI();
  }

  bool isPushNotificationsEnabled(String projectId, EventCategory type, String child) {
    final cleanChild = child.replaceAll(' ', '');

    final subs = _getSubscriptionsByCategory(projectId, type);
    return subs.isNotEmpty && (subs.every((sub) => storage.isSubscribedTo(sub, cleanChild)));
  }

  List<HookSubscription> _getSubscriptionsByCategory(String projectId, EventCategory category) {
    final subs = subscriptions.value?.data
        ?.where((s) => s.publisherInputs.projectId == projectId && s.eventType.category == category)
        .toList();
    return subs ?? [];
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
