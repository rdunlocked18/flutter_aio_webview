import 'package:firebase_messaging/firebase_messaging.dart';

abstract class PushNotificationsHandler {
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("onBackgroundMessage: $message");
  }
}
