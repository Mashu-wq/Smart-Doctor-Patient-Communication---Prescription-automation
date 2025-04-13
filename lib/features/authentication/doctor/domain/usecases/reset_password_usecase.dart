import 'package:medisafe/features/authentication/doctor/data/repositories/doctor_auth_repository.dart';

class ResetPasswordUseCase {
  final DoctorAuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> execute(String email) async {
    await repository.resetPassword(email);
  }
}
