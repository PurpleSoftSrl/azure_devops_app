// ignore_for_file: unreachable_from_main, reason: the warning is wrong

import 'dart:developer';

import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/models/hook_subscriptions.dart';
import 'package:azure_devops/src/router/router.dart';
import 'package:azure_devops/src/services/overlay_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) log(message.data.toString());

  await Firebase.initializeApp();
}

class NotificationsService with AppLogger {
  factory NotificationsService() {
    return _instance ??= NotificationsService._();
  }

  NotificationsService._();

  static NotificationsService? _instance;

  bool _initialized = false;

  void dispose() {
    _instance = null;
  }

  Future<void> init({required String userId, required String organization}) async {
    setTag('NotificationsService');

    if (_initialized) return;

    final perm = await FirebaseMessaging.instance.requestPermission();
    if (perm.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((msg) => _handleNotification(msg.data));

    FirebaseMessaging.onMessage.listen((msg) {
      return OverlayService.snackbar(
        msg.notification?.title ?? '',
      );
    });

    await FirebaseMessaging.instance.subscribeToTopic(userId);
    await FirebaseMessaging.instance.subscribeToTopic(organization);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // handle push notification when app is terminated
      _handleNotification(initialMessage.data);
    }

    _initialized = true;
  }

  void _handleNotification(Map<String, dynamic> data) {
    final type = EventType.fromString(data['eventType'].toString());

    log('Received notification type $type with data: $data');

    switch (type) {
      case EventType.approvalPending:
      case EventType.approvalCompleted:
      case EventType.buildCompleted:
        _handlePipelineNotification(data);
      case EventType.pullRequestCreated:
      case EventType.pullRequestUpdated:
      case EventType.pullRequestCommented:
        _handlePullRequestNotification(data);
      case EventType.workItemCreated:
      case EventType.workItemUpdated:
        _handleWorkItemNotification(data);
      case EventType.unknown:
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  void _handlePipelineNotification(Map<String, dynamic> data) {
    final id = _parseInt(data['pipelineId']);
    final project = data['projectId']?.toString();
    if (id == null || project == null) {
      logErrorMessage('Invalid pipelineId or projectId');
      return;
    }

    log('Pipeline notification with id: $id and project: $project');
    AppRouter.goToPipelineDetail(id: id, project: project);
  }

  void _handleWorkItemNotification(Map<String, dynamic> data) {
    final id = _parseInt(data['workItemId']);
    final project = data['projectId']?.toString();
    if (id == null || project == null) {
      logErrorMessage('Invalid workItemId or projectId');
      return;
    }

    log('Work item notification with id: $id and project: $project');
    AppRouter.goToWorkItemDetail(id: id, project: project);
  }

  void _handlePullRequestNotification(Map<String, dynamic> data) {
    final id = _parseInt(data['pullRequestId']);
    final project = data['projectId']?.toString();
    final repository = data['repositoryId']?.toString();
    if (id == null || project == null || repository == null) {
      logErrorMessage('Invalid pullRequestId, projectId, or repositoryId');
      return;
    }

    log('Pull request notification with id: $id and project: $project');
    AppRouter.goToPullRequestDetail(id: id, project: project, repository: repository);
  }

  int? _parseInt(dynamic val) {
    final id = val.toString();
    return int.tryParse(id);
  }
}
