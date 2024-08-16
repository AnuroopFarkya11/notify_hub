`notif_sync` is a Flutter package designed to manage notifications efficiently. It integrates Firebase Cloud Messaging, displays notifications using the local notification system, and stores them in Hive for offline access and historical data review.

## Features

- Firebase Messaging integration for handling incoming notifications.
- Local notifications to display alerts to the user.
- Persistent storage of notifications using Hive for offline access.


## Getting started

To start using `notif_sync`, ensure that your Flutter project is set up with Firebase. You will need to:
- Configure Firebase in your project by following the [Firebase setup instructions](https://firebase.google.com/docs/flutter/setup).
- Add `notif_sync` to your `pubspec.yaml` dependencies.

```yaml
dependencies:
  flutter:
    sdk: flutter
  notif_sync: ^1.0.0
