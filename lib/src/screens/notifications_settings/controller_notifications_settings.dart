part of notifications_settings;

class _NotificationsSettingsController {
  _NotificationsSettingsController._(this.api, this.storage);

  final AzureApiService api;
  final StorageService storage;

  final data = ValueNotifier<ApiResponse<List<HookSubscription>>?>(null);
  List<Project> projects = <Project>[];

  Future<void> init() async {
    projects = storage.getChosenProjects().toList();

    final res = await api.getSubscriptions();
    data.value = res;
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
        publisherInputs = PublisherInputs(
          projectId: projectId,
          definitionName: '', // TODO select definition
        );
      case EventType.pullRequestUpdated:
      case EventType.pullRequestMerged:
        publisherInputs = PublisherInputs(
          projectId: projectId,
          repository: '', // TODO select repository
          branch: '',
          mergeResult: 'Succeeded',
        );
      case EventType.workItemUpdated:
        publisherInputs = PublisherInputs(
          projectId: projectId,
        );
      case EventType.approvalPending:
      case EventType.approvalCompleted:
        publisherInputs = PublisherInputs(
          projectId: projectId,
          pipelineId: '', // TODO select pipeline
        );
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
      return OverlayService.error('Error', description: res.errorResponse?.body ?? 'Subscription not created');
    }

    await init();
  }

  void togglePushNotifications(String projectId, EventType type, {required bool value}) {
    if (!hasHookSubscription(projectId, type)) return;

    final subscription = _getSubscriptionByType(projectId, type);
    if (subscription == null) return;

    final topic = 'topic_${subscription.id}';

    if (value) {
      NotificationsService().subscribeToTopic(topic);
    } else {
      NotificationsService().unsubscribeFromTopic(topic);
    }

    storage.setSubscriptionStatus(subscription, isSubscribed: value);
  }

  bool isPushNotificationsEnabled(String projectId, EventType type) {
    final sub = _getSubscriptionByType(projectId, type);
    return sub != null && storage.isSubscribedTo(sub);
  }

  HookSubscription? _getSubscriptionByType(String projectId, EventType type) {
    final subscription =
        data.value?.data?.firstWhereOrNull((s) => s.publisherInputs.projectId == projectId && s.eventType == type);
    return subscription;
  }
}
