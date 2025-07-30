import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';
import 'package:medisafe/features/home/patient/presentation/screens/patient_profile_consultancy.dart';
import 'package:medisafe/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _rejectExpiredAppointments(String doctorId) async {
    final now = DateTime.now();
    final appointmentQuery = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('isConsulted', isEqualTo: false)
        .where('status', isEqualTo: 'Pending')
        .get();

    for (final doc in appointmentQuery.docs) {
      final data = doc.data();
      final String dateStr = data['date'] ?? '';
      final String timeStr = data['timeSlot'] ?? '';
      if (dateStr.isEmpty || timeStr.isEmpty) continue;

      try {
        final date = DateFormat('yyyy-MM-dd').parse(dateStr);
        final time = DateFormat('h:mm a').parse(timeStr);
        final appointmentStart = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        // If 30min have passed since appointment start and it's still pending, mark as "Rejected"
        if (now.isAfter(appointmentStart.add(const Duration(minutes: 30)))) {
          await doc.reference.update({'status': 'Rejected'});
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorName = ref.watch(doctorNameProvider);
    final String doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Trigger cleanup of expired appointments (safe for small user collections)
    _rejectExpiredAppointments(doctorId);

    return Scaffold(
      backgroundColor: AppColors.appColor,
      appBar: AppBar(
        title: Pacifico(text: "Home", size: 30.0),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            doctorName.when(
              data: (name) => AnimatedDoctorName(name: name),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text("Error loading doctor name"),
            ),
            const SizedBox(height: 30),
            const DigitalClock(),
            const SizedBox(height: 30),
            const Poppins(text: "Appointments", size: 24.0),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('appointments')
                    .where('doctorId', isEqualTo: doctorId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No appointments found.'));
                  }

                  // Filter: pending and not expired
                  final appointments = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (data['status'] != 'Pending') return false;

                    final String dateStr = data['date'] ?? '';
                    final String timeStr = data['timeSlot'] ?? '';
                    if (dateStr.isEmpty || timeStr.isEmpty) return false;

                    try {
                      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
                      final time = DateFormat('h:mm a').parse(timeStr);
                      final appointmentStart = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      // Only show if within 30 minutes window
                      return DateTime.now().isBefore(
                          appointmentStart.add(const Duration(minutes: 30)));
                    } catch (_) {
                      return false;
                    }
                  }).toList();

                  // ---- SORTING by (date, time) ascending ----
                  List<QueryDocumentSnapshot> sortedAppointments =
                      List.from(appointments);
                  sortedAppointments.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aDateStr = aData['date'] ?? '';
                    final bDateStr = bData['date'] ?? '';
                    final aTimeStr = aData['timeSlot'] ?? '00:00 AM';
                    final bTimeStr = bData['timeSlot'] ?? '00:00 AM';

                    DateTime aDateTime, bDateTime;
                    try {
                      final aDate = DateFormat('yyyy-MM-dd').parse(aDateStr);
                      final aTime = DateFormat('h:mm a').parse(aTimeStr);
                      aDateTime = DateTime(aDate.year, aDate.month, aDate.day,
                          aTime.hour, aTime.minute);
                    } catch (_) {
                      aDateTime = DateTime(1970);
                    }
                    try {
                      final bDate = DateFormat('yyyy-MM-dd').parse(bDateStr);
                      final bTime = DateFormat('h:mm a').parse(bTimeStr);
                      bDateTime = DateTime(bDate.year, bDate.month, bDate.day,
                          bTime.hour, bTime.minute);
                    } catch (_) {
                      bDateTime = DateTime(1970);
                    }

                    return aDateTime.compareTo(bDateTime);
                  });

                  // ---- GROUP by date AFTER sorting ----
                  final Map<String, List<QueryDocumentSnapshot>>
                      groupedAppointments = {};
                  for (var doc in sortedAppointments) {
                    final date = (doc.data() as Map<String, dynamic>)['date'] ??
                        'Unknown';
                    groupedAppointments.putIfAbsent(date, () => []);
                    groupedAppointments[date]!.add(doc);
                  }
                  final sortedDates = groupedAppointments.keys.toList()
                    ..sort((a, b) {
                      try {
                        final aDate = DateFormat('yyyy-MM-dd').parse(a);
                        final bDate = DateFormat('yyyy-MM-dd').parse(b);
                        return aDate.compareTo(bDate);
                      } catch (_) {
                        return a.compareTo(b);
                      }
                    }); // Sorted by date string

                  if (appointments.isEmpty) {
                    return const Center(child: Text('No appointments found.'));
                  }

                  // UI Display
                  return ListView.builder(
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final date = sortedDates[index];
                      final dateAppointments = groupedAppointments[date]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 12.0, bottom: 8.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.buttonColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "Date: $date",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.appColor,
                                ),
                              ),
                            ),
                          ),
                          ...dateAppointments.map((appointment) {
                            final data =
                                appointment.data() as Map<String, dynamic>;
                            final userId = data['userId'];
                            final timeStr = data['timeSlot'] ?? 'N/A';
                            final isConsulted = data['isConsulted'] ?? false;
                            final status = isConsulted ? "Visited" : "Pending";

                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('patients')
                                  .doc(userId)
                                  .get(),
                              builder: (context, patientSnapshot) {
                                if (patientSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const ListTile(
                                    title: Text("Loading..."),
                                    subtitle: Text("Fetching patient data"),
                                  );
                                }
                                if (!patientSnapshot.hasData ||
                                    !patientSnapshot.data!.exists) {
                                  return const ListTile(
                                    title: Text("Unknown Patient"),
                                    subtitle: Text("Patient data not found"),
                                  );
                                }
                                final patientData = patientSnapshot.data!.data()
                                    as Map<String, dynamic>;
                                final patientName =
                                    patientData['first_name'] ?? 'Unknown';
                                final contactNumber =
                                    patientData['contact_number'] ?? 'N/A';

                                return AppointmentCard(
                                  patientName: patientName,
                                  time: timeStr,
                                  status: status,
                                  contactNumber: contactNumber,
                                  patientId: userId,
                                );
                              },
                            );
                          }),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Supporting UI Widgets ---

class AnimatedDoctorName extends StatefulWidget {
  final String name;
  const AnimatedDoctorName({super.key, required this.name});

  @override
  State<AnimatedDoctorName> createState() => _AnimatedDoctorNameState();
}

class _AnimatedDoctorNameState extends State<AnimatedDoctorName>
    with SingleTickerProviderStateMixin {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 1000),
      opacity: _visible ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 3000),
        offset: _visible ? Offset.zero : const Offset(-0.2, 0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.appColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
              child: OpenSans(
            text: "Hello, Dr. ${widget.name}",
            size: 28.0,
            color: AppColors.buttonColor,
            fontWeight: FontWeight.bold,
          )),
        ),
      ),
    );
  }
}

class DigitalClock extends StatefulWidget {
  const DigitalClock({super.key});

  @override
  State<DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  late Stream<DateTime> _clockStream;

  @override
  void initState() {
    super.initState();
    _clockStream = Stream.periodic(
      const Duration(seconds: 1),
      (_) => DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _clockStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final currentTime = snapshot.data!;
          final timeFormatted = DateFormat('h:mm:ss a').format(currentTime);

          return Center(
            child: Text(
              timeFormatted,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String patientName;
  final String time;
  final String status;
  final String contactNumber;
  final String patientId;

  const AppointmentCard({
    super.key,
    required this.patientName,
    required this.time,
    required this.status,
    required this.contactNumber,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'visited':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PatientProfileForConsultancy(patientId: patientId)),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name: $patientName",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text("Contact: $contactNumber"),
                const SizedBox(height: 4),
                Text("Time: $time"),
                const SizedBox(height: 4),
                Text(
                  "Status: $status",
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
