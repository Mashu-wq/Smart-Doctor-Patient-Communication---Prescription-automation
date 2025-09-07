import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';

// Future<void> scheduleMedicineReminder({
//   required int id,
//   required String medicineName,
//   required String advice,
//   required DateTime date,
//   required String timeString,
// }) async {
//   // Map common named times to approximate time of day
//   Map<String, TimeOfDay> namedTimes = {
//     "Morning": TimeOfDay(hour: 8, minute: 0),
//     "Afternoon": TimeOfDay(hour: 14, minute: 0),
//     "Evening": TimeOfDay(hour: 19, minute: 0),
//     "Night": TimeOfDay(hour: 21, minute: 0),
//   };
//
//   TimeOfDay? tod;
//   if (namedTimes.containsKey(timeString)) {
//     tod = namedTimes[timeString];
//   } else {
//     // Try parse explicit time e.g. "6:30 AM"
//     try {
//       final dt = DateFormat.jm().parse(timeString);
//       tod = TimeOfDay(hour: dt.hour, minute: dt.minute);
//     } catch (_) {
//       tod = TimeOfDay(hour: 8, minute: 0); // fallback default time
//     }
//   }
//
//   final scheduledDateTime =
//       DateTime(date.year, date.month, date.day, tod!.hour, tod.minute);
//
//   // Do not schedule notifications in the past
//   if (scheduledDateTime.isBefore(DateTime.now())) return;
//
//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: id,
//       channelKey: 'medicine_reminder',
//       title: 'Medicine Reminder: $medicineName',
//       body: 'Advice: $advice\nTake now.',
//       notificationLayout: NotificationLayout.Default,
//     ),
//     schedule: NotificationCalendar.fromDate(
//         date: scheduledDateTime, preciseAlarm: true),
//   );
// }

Future<void> scheduleMedicineRemindersForPeriod({
  required int idStart,
  required String medicineName,
  required String advice,
  required DateTime startDate,
  required List<String> times,
  required int durationDays,
}) async {
  Map<String, TimeOfDay> namedTimes = {
    "Morning": TimeOfDay(hour: 8, minute: 0),
    "Afternoon": TimeOfDay(hour: 14, minute: 0),
    "Evening": TimeOfDay(hour: 19, minute: 0),
    "Night": TimeOfDay(hour: 21, minute: 0),
  };
  int notifCounter = 0;
  for (int day = 0; day < durationDays; day++) {
    final date = startDate.add(Duration(days: day));
    for (var t in times) {
      final tod = namedTimes[t] ?? TimeOfDay(hour: 8, minute: 0);
      final sched =
          DateTime(date.year, date.month, date.day, tod.hour, tod.minute);
      if (sched.isBefore(DateTime.now())) continue; // don't schedule in past

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: idStart + notifCounter,
          channelKey: 'medicine_reminder',
          title: 'Medicine Reminder: $medicineName',
          body: 'Advice: $advice\nTake at ${t}.',
          notificationLayout: NotificationLayout.Default,
        ),
        schedule:
            NotificationCalendar.fromDate(date: sched, preciseAlarm: true),
      );
      notifCounter++;
    }
  }
}

class DoctorProfileWithHistoryScreen extends StatelessWidget {
  final String doctorId;
  final String patientId;

  const DoctorProfileWithHistoryScreen({
    super.key,
    required this.doctorId,
    required this.patientId,
  });
  static final Set<String> _scheduledMedicineKeys = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Poppins(text: "Doctor's Profile", size: 26.0),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('doctors')
            .doc(doctorId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Doctor not found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['doctor_name'] ?? 'Unknown Doctor';
          final specialization = data['specialization'] ?? 'Unknown';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Poppins(
                      text: "Dr. $name",
                      size: 23.0,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 8),
                    Poppins(
                      text: "Specialist in $specialization",
                      size: 14.0,
                    ),
                    // Text(
                    //   "Specialist in $specialization",
                    //   style: const TextStyle(
                    //     fontSize: 18,
                    //     color: Colors.white70,
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Poppins(
                    text: "Prescriptions Given to You:",
                    size: 20.0,
                  )),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('patients')
                      .doc(patientId)
                      .collection('prescriptions')
                      .where('doctorId', isEqualTo: doctorId)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snap.hasData || snap.data!.docs.isEmpty) {
                      return const Center(
                          child: Text(
                              "No prescription history found from this doctor."));
                    }

                    final history = snap.data!.docs;

                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      int notifIdBase =
                          100000; // Ensure unique IDs per prescription/medicine
                      int notifCounter = 0;

                      for (var doc in history) {
                        final prescData = doc.data() as Map<String, dynamic>;
                        final DateTime startDate =
                            (prescData['timestamp'] as Timestamp?)?.toDate() ??
                                DateTime.now();
                        final meds = prescData['medicines'] ?? [];
                        for (var med in meds) {
                          final String medName = med['medicine'] ?? 'Medicine';
                          final String advice =
                              med['advice'] ?? 'Follow instructions';
                          final times = (med['times'] is List)
                              ? List<String>.from(med['times'])
                              : <String>[];

                          // Parse duration from dosage text e.g. "2 times for 30 days"
                          int duration = 1; // default
                          final dosage = med['dosage']?.toString() ?? '';
                          final match =
                              RegExp(r'(\\d+)\\s*days').firstMatch(dosage);
                          if (match != null && match.groupCount >= 1) {
                            duration = int.tryParse(match.group(1) ?? '') ?? 1;
                          } else {
                            duration =
                                1; // If parsing fails, schedule just once
                          }

                          // Create a unique key to avoid duplicate scheduling in this session
                          String medicineKey =
                              "$startDate|$medName|$advice|${times.join(',')}|$duration";
                          if (!_scheduledMedicineKeys.contains(medicineKey)) {
                            _scheduledMedicineKeys.add(medicineKey);
                            await scheduleMedicineRemindersForPeriod(
                              idStart: notifIdBase + notifCounter * 1000,
                              medicineName: medName,
                              advice: advice,
                              startDate: startDate,
                              times: times,
                              durationDays: duration,
                            );
                          }
                          notifCounter++;
                        }
                      }
                    });

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final medData =
                            history[index].data() as Map<String, dynamic>;
                        final List<dynamic> meds = medData['medicines'] ?? [];

                        final date = (medData['timestamp'] as Timestamp?)
                                ?.toDate()
                                .toLocal()
                                .toString()
                                .split(' ')[0] ??
                            '';

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                          color: AppColors.buttonColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Date: $date",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.appColor,
                                      ),
                                    ),
                                    const Icon(Icons.assignment_turned_in,
                                        color: AppColors.appColor)
                                  ],
                                ),
                                const Divider(height: 20, thickness: 1),
                                ...meds.map((e) {
                                  final name = e['medicine'] ?? 'Unknown';
                                  final dosage = e['dosage'] ?? '';
                                  final advice = e['advice'] ?? '';
                                  final times = (e['times'] is List)
                                      ? (e['times'] as List).join(', ')
                                      : '';

                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.appColor,
                                        border: Border.all(
                                          color: AppColors.primaryColor
                                              .withOpacity(1.0),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "$name ($dosage)",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text("Times: $times"),
                                          const SizedBox(height: 4),
                                          Text("Advice: $advice"),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
