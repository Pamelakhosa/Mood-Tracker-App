import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  final bool _isInitialized = false;

  bool get isInitialzed => _isInitialized;


  //REQUEST PERMISSION
  Future<void> requestNotiPermission () async {
    if (await Permission.notification.isDenied){
      await Permission.notification.request();
    }
  }

  //INITIALZE
  Future<void> initNotification() async {
    if (_isInitialized) return; // prevent re-selection

    //Prepare android init setings
    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );


    //Initialize plugin
    await notificationsPlugin.initialize(InitializationSettings(android: initSettingsAndroid));
  }

  //NOTIFICATIONS DETAIL SETUP
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Daily Notification Channel',
        icon: '@mipmap/ic_launcher',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  //SHOW NOTIFICATION
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {

    if (!isInitialzed){
      await requestNotiPermission();
      await initNotification();
    }
    return notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails(),
    );
  }

}
