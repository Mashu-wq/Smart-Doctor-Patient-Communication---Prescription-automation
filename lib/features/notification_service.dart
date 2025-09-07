// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
//
// class NotificationService {
//   static final flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   static Future<void> initialize() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     final InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//     tz.initializeTimeZones();
//   }
//
//   static Future<void> scheduleMedicineReminder({
//     required int id,
//     required String message,
//     required DateTime scheduledTime,
//   }) async {
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       'Medicine Reminder',
//       message,
//       tz.TZDateTime.from(scheduledTime, tz.local),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'medisafe_channel_id',
//           'Medicine Reminders',
//           channelDescription: 'Channel for medicine reminder notifications',
//           importance: Importance.max,
//           priority: Priority.high,
//           playSound: true,
//           enableVibration: true,
//         ),
//       ),
//       androidScheduleMode:
//           AndroidScheduleMode.inexactAllowWhileIdle, // Required in v19+
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }
// }
