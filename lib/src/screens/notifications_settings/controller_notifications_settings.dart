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

  final pageMode = ValueNotifier<PageMode>(PageMode.user);

  Future<void> init() async {
    projects = storage.getChosenProjects().toList();

    final res = await api.getSubscriptions();
    if (res.isError) return;

    await Future.wait([
      for (final project in projects)
        for (final category in EventCategory.values) _getSubscriptionChildren(project.id!, category),
    ]);

    subscriptions.value = res;

    final userRes = await api.getUserToMention(email: api.user!.emailAddress!);
    _userId = userRes.data ?? '';

    if (_userId.isEmpty) _userIdError();
  }

  void showInfo() {
    OverlayService.bottomsheet(
      title: 'How to enable notifications',
      spaceUnderTitle: false,
      isScrollControlled: true,
      builder: (_) => _InfoBottomsheet(eventCategories: eventCategories),
    );
  }

  void setPageMode(Set<String> value) {
    pageMode.value = PageMode.values.firstWhere((e) => e.name == value.first);
  }

  bool hasHookSubscription(String projectId, EventCategory category) {
    final subscription = _getSubscriptionsByCategory(projectId, category);
    return subscription.isNotEmpty;
  }

  Future<void> createHookSubscription(String projectId, EventCategory category) async {
    if (hasHookSubscription(projectId, category)) return;

    for (final type in category.eventTypes) {
      final publisherInputs = PublisherInputs(projectId: projectId);

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
        final allAreas = _getAllAreas(res.data ?? []);
        _subscriptionChildren[key] = allAreas;
      case EventCategory.unknown:
        _subscriptionChildren[key] = [];
    }
  }

  List<String> _getAllAreas(List<AreaOrIteration> areas) {
    final allAreas = <String>[];

    for (final area in areas) {
      allAreas.add(area.escapedAreaPath);

      if (area.children != null && area.children!.isNotEmpty) {
        allAreas.addAll(_getAllAreas(area.children!));
      }
    }

    return allAreas;
  }

  List<String> getCachedSubscriptionChildren(String projectId, EventCategory category) =>
      _subscriptionChildren['${projectId}_${category.name}'] ?? <String>[];

  void togglePushNotifications(String projectId, EventCategory category, String child, {required bool isEnabled}) {
    if (_userId.isEmpty) return _userIdError();

    final cleanChild = child.cleaned;

    final topics = switch (category) {
      // Pipelines notifications are sent to all subscribed users, not only the one who triggered the event
      EventCategory.pipelines => ['topic_${projectId}_$cleanChild'],
      EventCategory.pullRequests => ['topic_${projectId}_${cleanChild}_$_userId'],
      // We use both email and userId for work items because the userId is not always available in the devops webhooks
      EventCategory.workItems => [
          'topic_${projectId}_${cleanChild}_${api.user!.emailAddress!.replaceAll('@', '.')}',
          'topic_${projectId}_${cleanChild}_$_userId',
        ],
      EventCategory.unknown => <String>[],
    };

    if (topics.isEmpty) {
      OverlayService.error('Error', description: 'Event category $category is not supported');
      return;
    }

    if (isEnabled) {
      for (final topic in topics) {
        NotificationsService().subscribeToTopic(topic);
      }
    } else {
      for (final topic in topics) {
        NotificationsService().unsubscribeFromTopic(topic);
      }
    }

    storage.setSubscriptionStatus(projectId, category, cleanChild, isSubscribed: isEnabled);

    _refreshUI();
  }

  bool isPushNotificationsEnabled(String projectId, EventCategory category, String child) {
    final cleanChild = child.cleaned;
    return storage.isSubscribedTo(projectId, category, cleanChild);
  }

  List<HookSubscription> _getSubscriptionsByCategory(String projectId, EventCategory category) {
    final subs = subscriptions.value?.data
        ?.where((s) => s.publisherInputs.projectId == projectId && s.eventType.category == category)
        .toList();
    return subs ?? [];
  }

  bool hasAllHookSubscriptions(String projectId) {
    if (pageMode.value == PageMode.user) return true;

    return EventCategory.values
        .where((c) => c != EventCategory.unknown)
        .every((c) => hasHookSubscription(projectId, c));
  }

  bool isAllPushNotificationsEnabled(String projectId) {
    return EventCategory.values.where((c) => c != EventCategory.unknown).every((category) {
      if (pageMode.value == PageMode.admin && !hasHookSubscription(projectId, category)) return false;

      final children = _subscriptionChildren['${projectId}_${category.name}'] ??= [];
      return children.every((child) => isPushNotificationsEnabled(projectId, category, child));
    });
  }

  void toggleAllPushNotifications(String projectId, {required bool isEnabled}) {
    for (final category in EventCategory.values.where((c) => c != EventCategory.unknown)) {
      if (pageMode.value == PageMode.admin && !hasHookSubscription(projectId, category)) continue;

      final children = _subscriptionChildren['${projectId}_${category.name}'] ??= [];
      for (final child in children) {
        togglePushNotifications(projectId, category, child, isEnabled: isEnabled);
      }
    }
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

extension on String {
  String get cleaned {
    return replaceAll(RegExp('[^a-zA-Z0-9._-]'), '');
  }
}

enum PageMode {
  user,
  admin,
}
