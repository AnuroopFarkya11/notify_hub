import 'package:flutter/material.dart';
import 'package:notify_hub/src/modal/notification_item.dart';

class BasicNotificationTile1 extends StatelessWidget {
  final NotificationItem notification;
  final Key key;
  final void Function(DismissDirection direction)? onDismissed;

  const BasicNotificationTile1(
      {required this.key, required this.notification, this.onDismissed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key,
      direction: DismissDirection.endToStart,
      onDismissed: onDismissed,
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        title: Text(notification.title),
        subtitle: Text(notification.body),
        trailing: Text(notification.timeDifference),
      ),
    );
  }
}
