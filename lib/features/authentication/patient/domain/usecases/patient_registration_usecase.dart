import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:medisafe/features/authentication/patient/data/repositories/patient_auth_repository.dart';

class PatientRegistrationUseCase {
  final PatientAuthRepository repository;

  PatientRegistrationUseCase(this.repository);

  // Method to register patient and store information in Firestore and Storage
  Future<void> execute({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String address,
    required String contactNumber,
    required String gender,
    required DateTime dateOfBirth,
    required int age,
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
            FirebaseStorage.instance.ref().child('patient_profiles/$uid.jpg');
        await storageRef.putFile(profileImage);
        profileImageUrl = await storageRef.getDownloadURL();
      }

      // Step 3: Save patient information in Firestore
      await FirebaseFirestore.instance.collection('patients').doc(uid).set({
        'first_name': firstName,
        'last_name': lastName,
        'address': address,
        'email': email,
        'contact_number': contactNumber,
        'gender': gender,
        'date_of_birth': dateOfBirth.toIso8601String(),
        'age': age,
        'profile_image_url': profileImageUrl ?? '',
        'prescription': null,
      });
    } catch (e) {
      throw Exception("Failed to register patient: $e");
    }
  }
}
