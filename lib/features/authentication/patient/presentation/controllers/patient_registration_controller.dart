// Controller for Patient Registration
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/authentication/patient/domain/usecases/patient_registration_usecase.dart';
import 'package:medisafe/features/authentication/patient/domain/usecases/use_case_providers.dart';

final patientRegistrationController =
    StateNotifierProvider<PatientRegistrationController, AsyncValue<void>>(
  (ref) => PatientRegistrationController(
      ref.read(patientRegistrationUseCaseProvider)),
);

class PatientRegistrationController extends StateNotifier<AsyncValue<void>> {
  final PatientRegistrationUseCase registerUseCase;

  PatientRegistrationController(this.registerUseCase)
      : super(const AsyncValue.data(null));

  Future<void> registerPatient({
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
    state = const AsyncValue.loading();
    try {
      await registerUseCase.execute(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        address: address,
        contactNumber: contactNumber,
        gender: gender,
        dateOfBirth: dateOfBirth,
        age: age,
        profileImage: profileImage,
      );
      // If successful, update the state
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
