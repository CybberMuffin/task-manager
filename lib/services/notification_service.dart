import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;

  NotificationService() {
    initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {}

  Future sheludedNotification(
      int id, String title, String description, DateTime dateTime) async {
    var androidPlatformChannelSpecifics =
        AndroidNotificationDetails('$id', title, description);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await notificationsPlugin.schedule(
        id, title, description, dateTime, platformChannelSpecifics);
  }

  Future deleteAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  Future deleteNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  Future allNotificiations() async {
    return notificationsPlugin.pendingNotificationRequests();
  }
}
