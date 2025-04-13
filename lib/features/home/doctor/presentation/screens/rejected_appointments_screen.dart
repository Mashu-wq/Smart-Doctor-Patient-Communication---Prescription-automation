import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';

class RejectedAppointmentsScreen extends StatelessWidget {
  const RejectedAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appColor,
      appBar: AppBar(
        title: Pacifico(text: "Rejected Appointments", size: 25.0),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointments')
              .where('status', isEqualTo: 'Pending')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text("No rejected appointments found."));
            }

            // Extract and filter rejected appointments only
            final rejectedAppointments = snapshot.data!.docs.where((doc) {
              final appointment = doc.data() as Map<String, dynamic>;
              final dateStr = appointment['date'] ?? '';
              final isConsulted = appointment['isConsulted'] ?? false;

              DateTime appointmentDate =
                  DateTime.tryParse(dateStr) ?? DateTime(2000);
              DateTime today = DateTime.now();

              // Appointment is in the past and not consulted
              return !isConsulted &&
                  appointmentDate.isBefore(today) &&
                  appointment['status'] == 'Pending';
            }).toList();

            if (rejectedAppointments.isEmpty) {
              return const Center(
                child: Text("No rejected appointments found."),
              );
            }

            return ListView.builder(
              itemCount: rejectedAppointments.length,
              itemBuilder: (context, index) {
                final doc = rejectedAppointments[index];
                final data = doc.data() as Map<String, dynamic>;
                final date = data['date'] ?? 'N/A';
                final timeSlot = data['timeSlot'] ?? 'N/A';
                final userId = data['userId'] ?? '';

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
                      status: "Rejected",
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

// Appointment Card UI Component
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
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $patientName",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Date: $date"),
            const SizedBox(height: 4),
            Text("Time: $time"),
            const SizedBox(height: 4),
            Text(
              "Status: $status",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
