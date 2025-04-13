import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';
import 'package:medisafe/features/home/doctor/presentation/screens/doctor_details_screen.dart';
import 'package:medisafe/features/home/patient/presentation/widgets/customBottomNavigationBar.dart';
import 'package:medisafe/models/doctor_model.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Pacifico(text: "My Appointments", size: 25.0),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('userId', isEqualTo: userId)
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

          // Sort the appointments by date
          final appointments = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data;
          }).toList();

          // Sort by date
          appointments.sort((a, b) {
            final dateA = DateTime.parse(a['date']);
            final dateB = DateTime.parse(b['date']);
            return dateA.compareTo(dateB); // Ascending order
          });

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Card(
                color: AppColors.primaryColor,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: OpenSans(
                    text: 'Dr. ${appointment['doctorName'] ?? 'Unknown'}',
                    size: 16.0,
                    color: AppColors.buttonColor,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${appointment['date'] ?? 'N/A'}'),
                      Text('Time: ${appointment['timeSlot'] ?? 'N/A'}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text(
                              'Do you want to delete this appointment?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          // Find the document ID for this appointment
                          final docId = snapshot.data!.docs[index].id;
                          await FirebaseFirestore.instance
                              .collection('appointments')
                              .doc(docId)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Appointment deleted successfully')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Failed to delete appointment: $e')),
                          );
                        }
                      }
                    },
                  ),
                  onTap: () async {
                    final doctorId = appointment['doctorId'];
                    final doctorDoc = await FirebaseFirestore.instance
                        .collection('doctors')
                        .doc(doctorId)
                        .get();

                    if (doctorDoc.exists) {
                      final doctor = Doctor.fromFirestore(doctorDoc);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorDetailsScreen(
                            doctor: doctor,
                            patiendId: '',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Doctor details not found.')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 2),
    );
  }
}
