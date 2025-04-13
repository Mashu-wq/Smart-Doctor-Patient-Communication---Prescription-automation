import 'package:medisafe/features/home/doctor/data/repositories/category_repository.dart';
import 'package:medisafe/models/category_model.dart';

class FetchCategoriesUseCase {
  final CategoryRepository repository;

  FetchCategoriesUseCase(this.repository);

  Future<List<Category>> execute() {
    return repository.fetchCategories();
  }
}
