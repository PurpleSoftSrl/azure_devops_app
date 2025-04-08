// ignore_for_file: unreachable_from_main, reason: the warning is wrong

import 'dart:developer';

import 'package:azure_devops/src/mixins/logger_mixin.dart';
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
    final type = data['notificationType'];

    switch (type) {
      default:
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}
