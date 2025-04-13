import 'package:medisafe/features/authentication/patient/data/repositories/patient_auth_repository.dart';

class ResetPasswordUseCase {
  final PatientAuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> execute(String email) async {
    await repository.resetPassword(email);
  }
}
