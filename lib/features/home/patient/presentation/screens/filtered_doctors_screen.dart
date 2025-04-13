// screens/filtered_doctors_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/home/patient/presentation/controllers/search_doctor_controller.dart';
import 'package:medisafe/models/doctor_model.dart';
import 'package:medisafe/models/search_filter_model.dart';

class FilteredDoctorsScreen extends ConsumerWidget {
  final SearchFilter filter;

  const FilteredDoctorsScreen({super.key, required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(searchDoctorControllerProvider.notifier).searchDoctors(filter);
    final doctorsState = ref.watch(searchDoctorControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Selected area ${filter.area}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: doctorsState.when(
        data: (doctors) => _buildDoctorsList(doctors),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDoctorsList(List<Doctor> doctors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "All ${filter.category ?? "Doctors"}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return _buildDoctorCard(doctor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(doctor.profileImageUrl),
          radius: 30,
        ),
        title: Text('Dr. ${doctor.name}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doctor.qualifications,
                style: const TextStyle(color: Colors.grey)),
            Text(doctor.availableTime),
            Text('${doctor.clinicName} • ${doctor.area}',
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
