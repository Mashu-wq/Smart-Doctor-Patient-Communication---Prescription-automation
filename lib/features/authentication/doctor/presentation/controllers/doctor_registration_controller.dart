import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/authentication/doctor/domain/usecases/doctor_registration_usecase.dart';
import 'package:medisafe/features/authentication/doctor/domain/usecases/use_case_providers.dart';

// Controller for Doctor Registration
final doctorRegistrationController =
    StateNotifierProvider<DoctorRegistrationController, AsyncValue<void>>(
  (ref) =>
      DoctorRegistrationController(ref.read(doctorRegistrationUseCaseProvider)),
);

class DoctorRegistrationController extends StateNotifier<AsyncValue<void>> {
  final DoctorRegistrationUseCase registerUseCase;

  DoctorRegistrationController(this.registerUseCase)
      : super(const AsyncValue.data(null));

  Future<void> registerDoctor({
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
    state = const AsyncValue.loading();
    try {
      await registerUseCase.execute(
        uid: '',
        email: email,
        password: password,
        doctorName: doctorName,
        clinicName: clinicName,
        contactNumber: contactNumber,
        gender: gender,
        qualifications: qualifications,
        availableTime: availableTime,
        about: about,
        dateOfBirth: dateOfBirth,
        profileImage: profileImage,
      );
      //If successful, update the state
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
