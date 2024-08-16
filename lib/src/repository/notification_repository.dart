import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notify_sync/src/modal/notification_item.dart';
import 'package:notify_sync/src/service/hive_service.dart';

abstract class NotificationBase {
  final String channelId = 'app_notification';
  final String channelName = 'High Importance Notifications';
  final String boxName = 'app_notification';
  final String hiveKey = 'notification_key';

  late FirebaseMessaging firebaseMessaging;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late HiveService hiveService;
  void Function(List<NotificationItem>)? onNotificationReceived;
  Future<void> initialize(int userId);
  Future<void> initializeLocalNotification();
  Future<void> setupNotificationChannels();
  Future<void> requestPermission();
  void configureFirebaseListeners();

  void handleMessage(RemoteMessage message);
  Future<String?> getDeviceToken();
  Future<NotificationSettings> getNotificationSettings();
  Future<void> showNotification(RemoteNotification notification);
  Future<void> testNotification();
  Future<void> storeNotification(NotificationItem notification);
  Future<void> getNotifications();
  Future<void> deleteNotification(NotificationItem notification);
}
