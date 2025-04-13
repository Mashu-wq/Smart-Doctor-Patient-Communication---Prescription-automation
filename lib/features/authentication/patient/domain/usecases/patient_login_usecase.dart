import 'package:medisafe/features/authentication/patient/data/repositories/patient_auth_repository.dart';

class PatientLoginUseCase {
  final PatientAuthRepository repository;

  PatientLoginUseCase(this.repository);

  Future<void> execute(String email, String password) async {
    await repository.signInWithEmail(email, password);
  }
}
