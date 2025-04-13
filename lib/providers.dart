import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/home/doctor/data/repositories/category_repository.dart';
import 'package:medisafe/features/home/doctor/data/repositories/doctor_repository.dart';
import 'package:medisafe/features/home/doctor/domain/usecases/fetch_categories_usecase.dart';
import 'package:medisafe/features/home/doctor/domain/usecases/fetch_doctor_usecases.dart';
import 'package:medisafe/features/home/patient/data/patient_repository.dart';
import 'package:medisafe/features/home/patient/domain/usecases/search_doctors_usecase.dart';
import 'package:medisafe/models/doctor_model.dart';
import 'package:medisafe/models/patient_model.dart';

final doctorRepositoryProvider =
    Provider<DoctorRepository>((ref) => DoctorRepository());
final categoryRepositoryProvider =
    Provider<CategoryRepository>((ref) => CategoryRepository());

final fetchDoctorsUseCaseProvider = Provider<FetchDoctorsUseCase>((ref) {
  return FetchDoctorsUseCase(ref.read(doctorRepositoryProvider));
});

final fetchCategoriesUseCaseProvider = Provider<FetchCategoriesUseCase>((ref) {
  return FetchCategoriesUseCase(ref.read(categoryRepositoryProvider));
});

final searchDoctorsUseCaseProvider = Provider<SearchDoctorsUseCase>((ref) {
  return SearchDoctorsUseCase(ref.read(doctorRepositoryProvider));
});

final doctorNameProvider = FutureProvider<String>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final doc = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(user.uid)
        .get();
    return doc.data()?['doctor_name'] ?? 'Doctor';
  }
  return 'Doctor';
});

// final doctorProfileProvider =
//     FutureProvider.family<Doctor, String>((ref, id) async {
//   if (id.isEmpty) {
//     throw Exception("Doctor ID is empty or null");
//   }

//   final repository = ref.read(doctorRepositoryProvider);
//   return repository.fetchDoctorProfile(id);
// });

final doctorProfileProvider = StreamProvider.family<Doctor, String>((ref, id) {
  if (id.isEmpty) {
    throw Exception("Doctor ID is empty or null");
  }

  final repository = ref.read(doctorRepositoryProvider);
  return repository
      .streamDoctorProfile(id); // Add this method in the repository
});

final updateDoctorProfileProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository();
});

final doctorProfilePictureProvider = FutureProvider<String>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final doc = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(user.uid)
        .get();
    return doc.data()?['profile_image_url'] ??
        'https://via.placeholder.com/150'; // Use placeholder URL if no picture
  }
  return 'https://via.placeholder.com/150'; // Default placeholder
});

//patients provider

final patientProfileProvider =
    FutureProvider.family<Patient, String>((ref, patientId) async {
  final repository = PatientRepository();
  return repository.fetchPatientProfile(patientId);
});
