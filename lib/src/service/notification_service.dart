import 'package:firebase_core/firebase_core.dart';
import 'package:notify_hub/src/modal/notification_item.dart';
import 'package:notify_hub/src/repository/notification_repository.dart';
import 'package:notify_hub/src/service/hive_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FirebaseNotificationService extends NotificationBase {
  FirebaseNotificationService._internal() {
    firebaseMessaging = FirebaseMessaging.instance;
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    hiveService = HiveService<NotificationItem>(boxName);
    Hive.registerAdapter(NotificationItemAdapter());
  }

  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();

  factory FirebaseNotificationService() {
    return _instance;
  }

  @override
  Future<void> initialize(int userId) async {

    await Firebase.initializeApp();
    await requestPermission();
    await getDeviceToken();
    await initializeLocalNotification();
    await setupNotificationChannels();
    await HiveService.init();
    configureFirebaseListeners();
  }

  @override
  Future<void> initializeLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Future<void> setupNotificationChannels() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  @override
  Future<void> requestPermission() async {
    await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  @override
  void configureFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received in foreground: ${message.messageId}');
      handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened: ${message.messageId}');
      handleMessage(message);
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  @override
  Future<void> handleMessage(RemoteMessage message) async {
    // Process the notification payload
    if (message.data.isNotEmpty) {
      print('Message data: ${message.data}');
      // Handle the data payload
    }
    if (message.notification != null) {
      final notificationItem = NotificationItem(
        title: message.notification!.title ?? 'No Title',
        body: message.notification!.body ?? 'No Body',
        receivedTime: DateTime.now(),
      );
      showNotification(message.notification!);
      storeNotification(notificationItem);
      if (onNotificationReceived != null) {
        List<NotificationItem> list = await getNotifications();
        onNotificationReceived!(list);
      }
    }
  }

  @override
  Future<String?> getDeviceToken() async {
    String? token = await firebaseMessaging.getToken();
    print("Device token : $token}");
    return token;
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    return await firebaseMessaging.getNotificationSettings();
  }

  @override
  Future<void> showNotification(RemoteNotification notification) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      notification.title,
      notification.body,
      platformChannelSpecifics,
    );
  }

  @override
  Future<void> testNotification() async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification.',
      platformChannelSpecifics,
    );
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print("Ios notfication invoked: $id | $title | $body | $payload");
  }

  @override
  Future<void> storeNotification(NotificationItem notification) async {
    await hiveService.addData<NotificationItem>(notification);
  }

  @override
  Future<List<NotificationItem>> getNotifications() async {
    print("getNotifications invoked");
    return await hiveService.getDataList<NotificationItem>();
  }

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
    await Hive.initFlutter();
    await Hive.openBox<NotificationItem>('app_notification');
    if (message.notification != null) {
      final notificationItem = NotificationItem(
        title: message.notification!.title ?? 'No Title',
        body: message.notification!.body ?? 'No Body',
        receivedTime: DateTime.now(),
      );
      final box = Hive.box<NotificationItem>('app_notification');
      await box.add(notificationItem);
    }
  }

  @override
  Future<void> deleteNotification(NotificationItem notification) async {
    print('deleteNotification invoked');

    await hiveService.deleteData<NotificationItem>(notification);
    var list = await getNotifications();

    print('List : ${list.toList().toString()}');
    // if (onNotificationReceived != null) {
    //   List<NotificationItem> list = await getNotifications();
    //   onNotificationReceived!(list);
    // }
  }
}
