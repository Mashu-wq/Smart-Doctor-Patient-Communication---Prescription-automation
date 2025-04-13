import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VisitedAppointmentsScreen extends StatelessWidget {
  const VisitedAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get today's date in 'yyyy-MM-dd' format
    final String today = DateTime.now().toIso8601String().substring(0, 10);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Visited Appointments"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointments')
              .where('status',
                  isEqualTo: 'Visited') // Filter visited appointments
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
              return const Center(
                child: Text("No visited appointments found."),
              );
            }

            // Filter appointments excluding today's date
            final visitedAppointments = snapshot.data!.docs.where((doc) {
              final appointmentDate = doc['date'] ?? '';
              return appointmentDate != today;
            }).toList();

            if (visitedAppointments.isEmpty) {
              return const Center(
                child: Text("No visited appointments found."),
              );
            }

            return ListView.builder(
              itemCount: visitedAppointments.length,
              itemBuilder: (context, index) {
                final appointment =
                    visitedAppointments[index].data() as Map<String, dynamic>;
                final date = appointment['date'] ?? 'N/A';
                final timeSlot = appointment['timeSlot'] ?? 'N/A';
                final status = appointment['status'] ?? 'Visited';
                final userId = appointment['userId'] ?? '';

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

                    final patientData =
                        patientSnapshot.data!.data() as Map<String, dynamic>;
                    final patientName = patientData['first_name'] ?? 'Unknown';

                    return AppointmentCard(
                      patientName: patientName,
                      date: date,
                      time: timeSlot,
                      status: status,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String patientName;
  final String date;
  final String time;
  final String status;

  const AppointmentCard({
    super.key,
    required this.patientName,
    required this.date,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Name: $patientName",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Date: $date"),
            Text("Time: $time"),
            // Status in green if visited
            Row(
              children: [
                const Text(
                  "Status: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: status == 'Visited' ? Colors.green : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
