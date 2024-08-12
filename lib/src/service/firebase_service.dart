import 'package:examples/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/foundation.dart';
import 'package:notify_hub/NotifSync.dart';

class FirebaseService {
  final FirebaseNotificationService _notificationService =
      FirebaseNotificationService();

  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  static Future<void> init() async {
    await Firebase.initializeApp(

      options: DefaultFirebaseOptions.currentPlatform
    );
    _instance._start();
  }

  Future<void> _start() async {
    try {
      await _notificationService.initialize(0);
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firebase: $e');
      }
      rethrow;
    }
  }
}
