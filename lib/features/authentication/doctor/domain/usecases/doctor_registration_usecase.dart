// import 'package:medisafe/features/authentication/doctor/data/repositories/doctor_auth_repository.dart';

// class DoctorRegistrationUseCase {
//   final DoctorAuthRepository repository;

//   DoctorRegistrationUseCase(this.repository);

//   Future<void> execute(String email, String password) async {
//     await repository.registerWithEmail(email, password);
//   }
// }

import 'dart:io';
import 'package:medisafe/features/authentication/doctor/data/repositories/doctor_auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DoctorRegistrationUseCase {
  final DoctorAuthRepository repository;

  DoctorRegistrationUseCase(this.repository);

  // Method to register doctor and store information in Firestore and Storage
  Future<void> execute({
    required String uid,
    required String email,
    required String password,
    required String doctorName,
    required String clinicName,
    required String contactNumber,
    required String gender,
    required String qualifications,
    required String availableTime,
    required String about,
    required DateTime dateOfBirth,
    required File? profileImage, // Optional file for profile image
  }) async {
    try {
      // Step 1: Register in Firebase Authentication
      final userCredential =
          await repository.registerWithEmail(email, password);

      if (userCredential?.user == null) {
        throw Exception("User registration failed");
      }

      String uid = userCredential!.user!.uid;

      // Step 2: Upload profile image to Firebase Storage (if available)
      String? profileImageUrl;
      if (profileImage != null) {
        final storageRef =
            FirebaseStorage.instance.ref().child('doctor_profiles/$uid.jpg');
        await storageRef.putFile(profileImage);
        profileImageUrl = await storageRef.getDownloadURL();
      }

      // Step 3: Save doctor information in Firestore
      await FirebaseFirestore.instance.collection('doctors').doc(uid).set({
        'doctor_name': doctorName,
        'clinic_name': clinicName,
        'email': email,
        'contact_number': contactNumber,
        'gender': gender,
        'qualifications': qualifications,
        'available_time': availableTime,
        'about': about,
        'date_of_birth': dateOfBirth.toIso8601String(),
        'profile_image_url': profileImageUrl ?? '',
      });
    } catch (e) {
      throw Exception("Failed to register doctor: $e");
    }
  }
}
