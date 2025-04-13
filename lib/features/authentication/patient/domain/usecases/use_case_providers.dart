// Provider for DoctorAuthRepository
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/authentication/patient/data/repositories/patient_auth_repository.dart';
import 'package:medisafe/features/authentication/patient/domain/usecases/patient_login_usecase.dart';
import 'package:medisafe/features/authentication/patient/domain/usecases/patient_registration_usecase.dart';

final patientAuthRepositoryProvider = Provider<PatientAuthRepository>((ref) {
  return PatientAuthRepository();
});

// Provider for DoctorLoginUseCase
final patientLoginUseCaseProvider = Provider<PatientLoginUseCase>((ref) {
  return PatientLoginUseCase(ref.read(patientAuthRepositoryProvider));
});

// Provider for DoctorRegistrationUseCase
final patientRegistrationUseCaseProvider =
    Provider<PatientRegistrationUseCase>((ref) {
  return PatientRegistrationUseCase(ref.read(patientAuthRepositoryProvider));
});
