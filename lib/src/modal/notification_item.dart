import 'package:hive/hive.dart';

part 'notification_item.g.dart'; // Name it according to the file

@HiveType(typeId: 0)
class NotificationItem extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String body;

  @HiveField(2)
  final DateTime receivedTime;

  NotificationItem({
    required this.title,
    required this.body,
    required this.receivedTime,
  });

  String get timeDifference {
    final now = DateTime.now();
    final difference = now.difference(receivedTime);
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
