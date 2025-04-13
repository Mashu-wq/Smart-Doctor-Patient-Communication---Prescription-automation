import 'package:medisafe/features/home/doctor/data/repositories/doctor_repository.dart';
import 'package:medisafe/models/doctor_model.dart';

class FetchDoctorsUseCase {
  final DoctorRepository repository;

  FetchDoctorsUseCase(this.repository);

  Stream<List<Doctor>> execute() {
    return repository.fetchDoctors();
  }
}
