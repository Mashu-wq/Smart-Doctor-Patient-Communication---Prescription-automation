import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';

class MedicationReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchAndScheduleReminders(String patientId) async {
    final prescriptionSnap = await _firestore
        .collection('patients')
        .doc(patientId)
        .collection('prescriptions')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (prescriptionSnap.docs.isEmpty) return;

    final prescription = prescriptionSnap.docs.first.data();
    final medicines =
        List<Map<String, dynamic>>.from(prescription['medicines'] ?? []);

    for (var med in medicines) {
      final name = med['medicine'];
      final times = List<String>.from(med['times']);

      for (var time in times) {
        await scheduleReminder(name, time);
      }
    }
  }

  Future<void> scheduleReminder(String medicineName, String timeLabel) async {
    final now = DateTime.now();
    final hourMinute = _convertTimeLabelToTime(timeLabel);

    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      hourMinute['hour']!,
      hourMinute['minute']!,
    );

    // If scheduled time has already passed today, schedule for tomorrow
    final reminderTime = scheduledTime.isBefore(now)
        ? scheduledTime.add(const Duration(days: 1))
        : scheduledTime;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'medication_reminder',
        title: 'Time for your medicine 💊',
        body: 'Please take "$medicineName" now.',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: reminderTime.hour,
        minute: reminderTime.minute,
        second: 0,
        repeats: true,
      ),
    );
  }

  Map<String, int> _convertTimeLabelToTime(String label) {
    switch (label.toLowerCase()) {
      case 'morning':
        return {'hour': 8, 'minute': 0};
      case 'afternoon':
        return {'hour': 13, 'minute': 0};
      case 'evening':
        return {'hour': 19, 'minute': 0};
      default:
        return {'hour': 9, 'minute': 0}; // fallback time
    }
  }
}
