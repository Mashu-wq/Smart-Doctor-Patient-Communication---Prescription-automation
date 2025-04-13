import 'package:medisafe/features/authentication/doctor/data/repositories/doctor_auth_repository.dart';

class DoctorLoginUseCase {
  final DoctorAuthRepository repository;

  DoctorLoginUseCase(this.repository);

  Future<void> execute(String email, String password) async {
    await repository.signInWithEmail(email, password);
  }
}
