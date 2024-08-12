import 'dart:async';

import 'package:examples/src/constants/app_constant.dart';
import 'package:examples/src/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:notify_hub/NotifSync.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  /// Instance of notification service
  final FirebaseNotificationService _notificationService =
      FirebaseNotificationService();

  /// List of notification
  List<NotificationItem> _notifications = [];

  /// Group notifications on basis of there day
  Map<String, List<NotificationItem>> _groupedNotificationsByDateMap = {};

  /// Periodic timer Subscriptions
  Timer? timerSubscription;

  /// Callback to get notification list
  onNotificationReceived(List<NotificationItem> notificationList) {
    setState(() {
      _notifications = notificationList;
      _notifications.sort((a, b) => b.receivedTime.compareTo(a.receivedTime));
      _groupedNotificationsByDateMap =
          AppUtils.groupNotificationsByDate(_notifications);
    });
  }

  Future<void> getNotificationsFromHive()async{
    _notifications = await _notificationService.getNotifications();
    _notifications.sort((a, b) => b.receivedTime.compareTo(a.receivedTime));
    _groupedNotificationsByDateMap =
        AppUtils.groupNotificationsByDate(_notifications);
    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();

    /// Initialising the callback for notification
    _notificationService.onNotificationReceived = onNotificationReceived;

    /// Get local notification
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timestamp)async{
      await getNotificationsFromHive();
      timerSubscription=Timer.periodic(const Duration(minutes: 1), (time){
        setState(() {
          
        });
      });
    });
  }

  @override
  void dispose() {
    timerSubscription?.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstant.title),
        centerTitle: true,
      ),
      body: ListView(
        children: _groupedNotificationsByDateMap.entries.map((entry) {
          final dateKey = entry.key;
          final items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  dateKey,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              ...items.map((notification) => BasicNotificationTile1(
                    notification: notification,
                    key: Key(notification.hashCode.toString()),
                    onDismissed: (direction) {
                      _notificationService.deleteNotification(notification);
                    },
                  )),
            ],
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.notifications_active_outlined),
        onPressed: () {},
      ),
    );
  }
}
