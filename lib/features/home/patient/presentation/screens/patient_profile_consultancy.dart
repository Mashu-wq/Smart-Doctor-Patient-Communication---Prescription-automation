import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medisafe/core/primary_color.dart';
import 'package:medisafe/features/home/patient/presentation/screens/prescription/prescribe_medicine.dart';

class PatientProfileForConsultancy extends ConsumerWidget {
  final String patientId;

  const PatientProfileForConsultancy({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.appColor,
      appBar: AppBar(
        title: const Text("Patient Profile"),
        backgroundColor: AppColors.primaryColor,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('patients')
            .doc(patientId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Patient data not found"));
          }

          final patientData = snapshot.data!.data() as Map<String, dynamic>;
          final patientName = patientData['first_name'] ?? 'Unknown';
          final age = patientData['age'] ?? 'N/A';
          final gender = patientData['gender'] ?? 'N/A';
          final contact = patientData['contact_number'] ?? 'N/A';
          final profileImageUrl = patientData['profile_image_url'] ?? '';

          return LayoutBuilder(
            builder: (context, constraints) {
              bool isWeb = constraints.maxWidth > 600;

              return SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: isWeb ? 500 : double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: isWeb ? 40 : 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : null,
                          child: profileImageUrl.isEmpty
                              ? const Icon(Icons.person,
                                  size: 50, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          patientName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$gender, $age years old",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          "Contact: $contact",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 20),
                        _buildActionButtons(context, contact, patientId),
                        const SizedBox(height: 30),
                        const Text(
                          "Medical History:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildPrescriptionHistory(context),
                        const SizedBox(height: 30),
                        const Text(
                          "Appointments:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildAppointmentList(context),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPrescriptionHistory(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .collection('prescriptions')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("No prescriptions added yet.");
        }

        final prescriptionDocs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: prescriptionDocs.length,
          itemBuilder: (context, index) {
            final data = prescriptionDocs[index].data() as Map<String, dynamic>;
            final medicines = data['medicines'] as List<dynamic>? ?? [];
            final timestamp = data['timestamp'] as Timestamp?;

            final dateTime = timestamp?.toDate() ?? DateTime.now();
            final dateStr = dateTime.toLocal().toString().split(' ')[0];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Prescription Date: $dateStr",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...medicines.map((med) {
                      final medicineName = med['medicine'] ?? '';
                      final dosage = med['dosage'] ?? '';
                      final advice = med['advice'] ?? '';
                      final timesData = med['times'];
                      List<String> timesList = [];

                      if (timesData is List) {
                        timesList = timesData.map((e) => e.toString()).toList();
                      } else {
                        final singleTime = med['time'] ?? '';
                        if (singleTime.isNotEmpty) {
                          timesList = [singleTime];
                        }
                      }
                      final timesString = timesList.join(', ');

                      return Text(
                        "- $medicineName ($dosage) at $timesString\n  Instructions: $advice",
                        style: const TextStyle(fontSize: 14),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppointmentList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: patientId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("No appointments found.");
        }

        final now = DateTime.now();

        final filteredDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] ?? '';
          final dateStr = data['date'] ?? '';
          final timeStr = data['timeSlot'] ?? '';
          if (status != 'Pending') return false;

          try {
            final fullStr = "$dateStr $timeStr";
            final appointmentTime =
                DateFormat("yyyy-MM-dd HH:mm").parse(fullStr);
            return appointmentTime.isAfter(now);
          } catch (_) {
            return false;
          }
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Text("No upcoming pending appointments.");
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final date = data['date'] ?? 'N/A';
            final timeSlot = data['timeSlot'] ?? 'N/A';
            final status = data['status'] ?? 'Scheduled';

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text("Date: $date\nTime: $timeSlot"),
                subtitle: Text("Status: $status"),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrescriptionFormScreen(
                          patientId: patientId,
                          appointmentId: doc.id,
                          doctorId: data[
                              'doctorId'], // Ensure doctorId is fetched properly from appointment doc
                          doctorName:
                              data['doctorName'], // Also fetch doctorName
                        ),
                      ),
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: const Text("Visit"),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButtons(
      BuildContext context, String callerName, String callerImageUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: FontAwesomeIcons.phone,
          label: "Voice Call",
          color: Colors.blue,
          onPressed: () {},
        ),
        const SizedBox(width: 40),
        _ActionButton(
          icon: FontAwesomeIcons.video,
          label: "Video Call",
          color: Colors.purple,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 30),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
