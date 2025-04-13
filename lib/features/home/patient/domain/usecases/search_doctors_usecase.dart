import 'package:medisafe/features/home/doctor/data/repositories/doctor_repository.dart';
import 'package:medisafe/models/doctor_model.dart';
import 'package:medisafe/models/search_filter_model.dart';

class SearchDoctorsUseCase {
  final DoctorRepository repository;

  SearchDoctorsUseCase(this.repository);

  Future<List<Doctor>> execute(SearchFilter filter) {
    return repository.searchDoctors(filter);
  }
}
