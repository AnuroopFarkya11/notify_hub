
import 'package:notify_hub/NotifSync.dart';

class AppUtils {
  static Map<String, List<NotificationItem>> groupNotificationsByDate(
      List<NotificationItem> notifications) {
    final Map<String, List<NotificationItem>> groupedNotifications = {};

    for (var notification in notifications) {
      final dateKey = getDateKey(notification.receivedTime);
      if (groupedNotifications.containsKey(dateKey)) {
        groupedNotifications[dateKey]!.add(notification);
      } else {
        groupedNotifications[dateKey] = [notification];
      }
    }

    return groupedNotifications;
  }

  static String getDateKey(DateTime date) {
    final now = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.subtract(Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}'; // Format other dates
    }
  }
}
