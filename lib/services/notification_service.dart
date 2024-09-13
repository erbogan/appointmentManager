import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService();

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher'); // Use the default Flutter launcher icon
    const DarwinInitializationSettings iosInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Benachrichtigung angeklickt: ${response.payload}'); 
      },
    );

    final androidImplementation = _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final isPermissionGranted = await androidImplementation.areNotificationsEnabled();
      if (isPermissionGranted == false) {
        print("Android-Benachrichtigungsberechtigung wurde nicht erteilt.");
      }
    }
  }

  Future<void> scheduleNotification(DateTime scheduledDateTime, String message) async {
    final tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id', 
      'channel_name', 
      channelDescription: 'Dieser Kanal wird für Terminbenachrichtigungen verwendet.', 
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Erinnerung', 
        message,
        scheduledTZDateTime,
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print("Fehler bei der Benachrichtigungsplanung: $e"); // "Bildirim zamanlama hatası"
    }
  }

  Future<void> scheduleAppointmentNotifications(DateTime appointmentDate, String message, bool notifyByPhone) async {
    final DateTime oneDayBefore = appointmentDate.subtract(Duration(days: 1));
    final DateTime oneDayBeforeNotificationTime = DateTime(
      oneDayBefore.year,
      oneDayBefore.month,
      oneDayBefore.day,
      12,
      0,
    );

    final DateTime twoHoursBeforeNotificationTime = appointmentDate.subtract(Duration(hours: 2));

    if (notifyByPhone) {
      try {
        await scheduleNotification(oneDayBeforeNotificationTime, 'Morgen um ${appointmentDate.hour}:${appointmentDate.minute} Uhr haben Sie einen Termin: $message'); // "Yarın saat ..."
        await scheduleNotification(twoHoursBeforeNotificationTime, 'In 2 Stunden haben Sie einen Termin: $message');
      } catch (e) {
        print("Fehler bei der Terminbenachrichtigung: $e"); 
      }
    }
  }
}
