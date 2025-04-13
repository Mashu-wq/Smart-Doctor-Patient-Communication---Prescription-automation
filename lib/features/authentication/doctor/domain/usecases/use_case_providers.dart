import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/authentication/doctor/data/repositories/doctor_auth_repository.dart';
import 'package:medisafe/features/authentication/doctor/domain/usecases/doctor_login_usecase.dart';
import 'package:medisafe/features/authentication/doctor/domain/usecases/doctor_registration_usecase.dart';

// Provider for DoctorAuthRepository
final doctorAuthRepositoryProvider = Provider<DoctorAuthRepository>((ref) {
  return DoctorAuthRepository();
});

// Provider for DoctorLoginUseCase
final doctorLoginUseCaseProvider = Provider<DoctorLoginUseCase>((ref) {
  return DoctorLoginUseCase(ref.read(doctorAuthRepositoryProvider));
});

// Provider for DoctorRegistrationUseCase
final doctorRegistrationUseCaseProvider =
    Provider<DoctorRegistrationUseCase>((ref) {
  return DoctorRegistrationUseCase(ref.read(doctorAuthRepositoryProvider));
});
