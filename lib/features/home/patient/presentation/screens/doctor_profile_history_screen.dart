import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';

class DoctorProfileWithHistoryScreen extends StatelessWidget {
  final String doctorId;
  final String patientId;

  const DoctorProfileWithHistoryScreen({
    super.key,
    required this.doctorId,
    required this.patientId,
  });

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
                                }).toList(),
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
