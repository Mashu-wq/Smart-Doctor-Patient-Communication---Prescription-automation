import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:medisafe/core/components.dart';
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
                        // ---------------------------
                        // PATIENT PROFILE
                        // ---------------------------
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

                        // ---------------------------
                        // ACTION BUTTONS (CALLS)
                        // ---------------------------
                        _buildActionButtons(context, contact, patientId),
                        const SizedBox(height: 30),

                        // ---------------------------
                        // MEDICAL HISTORY (PRESCRIPTIONS)
                        // ---------------------------
                        const Text(
                          "Medical History:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildPrescriptionHistory(context),
                        const SizedBox(height: 30),

                        // ---------------------------
                        // APPOINTMENTS LIST
                        // ---------------------------
                        const Text(
                          "Appointments:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildAppointmentList(context),
                        const SizedBox(height: 30),

                        // ---------------------------
                        // PRESCRIBE MEDICINE BUTTON
                        // ---------------------------
                        _buildPrescribeMedicineButton(context),
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

  // -----------------------------------
  // REAL-TIME MEDICAL HISTORY
  // -----------------------------------
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

                      // Attempt to read 'times' as a list
                      final timesData = med['times'];
                      List<String> timesList = [];

                      if (timesData is List) {
                        timesList = timesData.map((e) => e.toString()).toList();
                      } else {
                        // If no 'times' list, fall back to 'time'
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

        // Filter to only future pending appointments
        final filteredDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] ?? '';
          final dateStr = data['date'] ?? '';
          final timeStr = data['timeSlot'] ?? '';

          // Only pending
          if (status != 'Pending') return false;

          // Parse datetime
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
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text("Date: $date\nTime: $timeSlot"),
                subtitle: Text("Status: $status"),
                trailing: _buildVisitButton(doc.id, status),
              ),
            );
          },
        );
      },
    );
  }

  // Build the "Visit" button (or "Visited" if already visited).
  Widget _buildVisitButton(String docId, String status) {
    if (status == 'Visited') {
      // Already visited -> disable button and show green color
      return ElevatedButton(
        onPressed: null, // Disabled
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
        ),
        child: const Text("Visited"),
      );
    } else {
      // Not visited -> show "Visit" button
      return ElevatedButton(
        onPressed: () async {
          await FirebaseFirestore.instance
              .collection('appointments')
              .doc(docId)
              .update({'status': 'Visited'});
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
        ),
        child: const Text("Visit"),
      );
    }
  }

  // -----------------------------------
  // ACTION BUTTONS (Voice/Video Call)
  // -----------------------------------
  Widget _buildActionButtons(
      BuildContext context, String callerName, String callerImageUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: FontAwesomeIcons.phone,
          label: "Voice Call",
          color: Colors.blue,
          onPressed: () {
            // TODO: Navigate to your voice call screen
          },
        ),
        const SizedBox(width: 40),
        _ActionButton(
          icon: FontAwesomeIcons.video,
          label: "Video Call",
          color: Colors.purple,
          onPressed: () {
            // TODO: Navigate to your video call screen
          },
        ),
      ],
    );
  }

  // -----------------------------------
  // PRESCRIBE MEDICINE BUTTON
  // -----------------------------------
  Widget _buildPrescribeMedicineButton(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PrescriptionFormScreen(patientId: patientId),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Pacifico(
            text: "Prescribe Medicine",
            size: 18.0,
            color: AppColors.appColor,
          ),
        ));
  }
}

// -----------------------------------
// Reusable Action Button
// -----------------------------------
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
