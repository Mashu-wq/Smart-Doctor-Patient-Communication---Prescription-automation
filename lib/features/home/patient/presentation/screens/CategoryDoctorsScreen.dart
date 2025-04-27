import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';
import 'package:medisafe/features/home/doctor/presentation/screens/doctor_details_screen.dart';
import 'package:medisafe/models/category_model.dart';
import 'package:medisafe/models/doctor_model.dart';

class CategoryDoctorsScreen extends StatelessWidget {
  final Category category;

  const CategoryDoctorsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Fetch doctors for the selected category from Firestore
    final doctorsStream = FirebaseFirestore.instance
        .collection('doctors')
        .where('specialization', isEqualTo: category.name)
        .snapshots();

    return Scaffold(
      backgroundColor: AppColors.appColor,
      appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: Pacifico(text: '${category.name} Doctors', size: 25.0)
          //title: Text('${category.name} Doctors'),
          ),
      body: StreamBuilder<QuerySnapshot>(
        stream: doctorsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No doctors found.'));
          }

          // Map Firestore documents to Doctor objects
          final doctors = snapshot.data!.docs.map((doc) {
            return Doctor.fromFirestore(doc);
          }).toList();

          return ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorDetailsScreen(
                        doctor: doctor,
                        patiendId: '',
                      ),
                    ),
                  );
                },
                child: Card(
                  color: AppColors.primaryColor,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(doctor.profileImageUrl),
                    ),
                    title: Text(doctor.name),
                    subtitle: Text(
                        '${doctor.specialization} • ${doctor.experience} years experience'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
