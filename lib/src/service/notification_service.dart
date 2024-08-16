import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notify_sync/src/modal/notification_item.dart';
import 'package:notify_sync/src/repository/notification_repository.dart';
import 'package:notify_sync/src/service/hive_service.dart';

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

      handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {

      handleMessage(message);
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  @override
  Future<void> handleMessage(RemoteMessage message) async {
    // Process the notification payload
    if (message.data.isNotEmpty) {

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

  }

  @override
  Future<void> storeNotification(NotificationItem notification) async {
    await hiveService.addData<NotificationItem>(notification);
  }

  @override
  Future<List<NotificationItem>> getNotifications() async {

    return await hiveService.getDataList<NotificationItem>();
  }

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {

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


    await hiveService.deleteData<NotificationItem>(notification);



    // if (onNotificationReceived != null) {
    //   List<NotificationItem> list = await getNotifications();
    //   onNotificationReceived!(list);
    // }
  }
}
