import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/core/components.dart';
import 'package:medisafe/core/primary_color.dart';
import 'package:medisafe/features/home/doctor/presentation/screens/doctor_details_screen.dart';
import 'package:medisafe/features/home/patient/presentation/screens/search_doctor_screen.dart';
import 'package:medisafe/features/home/patient/presentation/widgets/customBottomNavigationBar.dart';
import 'package:medisafe/models/doctor_model.dart';
import 'package:medisafe/features/home/doctor/presentation/controllers/doctors_controller.dart';

class AvailableDoctorsScreen extends ConsumerWidget {
  const AvailableDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsState = ref.watch(doctorsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.appColor,
      appBar: _buildAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 600; // Detect web layout
          int crossAxisCount = isWeb ? 3 : 2; // Adjust grid layout

          return doctorsState.when(
            data: (doctors) => _buildDoctorsGrid(doctors, crossAxisCount),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, stack) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: $e'),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Pacifico(text: "Available Specialists", size: 22.0),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SearchDoctorScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDoctorsGrid(List<Doctor> doctors, int crossAxisCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, // Dynamic column count
          childAspectRatio: 0.65, // Adjust for better layout
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          return _buildDoctorCard(context, doctors[index]);
        },
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doctor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DoctorDetailsScreen(doctor: doctor, patiendId: ''),
          ),
        );
      },
      child: Card(
        color: AppColors.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(doctor.profileImageUrl),
                radius: 40, // Profile image size
              ),
              const SizedBox(height: 12),
              Text(
                'Dr. ${doctor.name}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                doctor.specialization,
                style: const TextStyle(color: Colors.blueGrey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                  Icons.star, '${doctor.experience} Years Experience'),
              _buildDetailRow(Icons.people, '${doctor.patients} Patients'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    );
  }
}
