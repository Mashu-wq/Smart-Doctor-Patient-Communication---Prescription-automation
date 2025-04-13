import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/home/doctor/domain/usecases/fetch_categories_usecase.dart';
import 'package:medisafe/providers.dart';
import 'package:medisafe/models/category_model.dart';

final categoriesControllerProvider = FutureProvider<List<Category>>((ref) {
  final fetchCategoriesUseCase = ref.read(fetchCategoriesUseCaseProvider);
  return fetchCategoriesUseCase.execute();
});

class CategoriesController extends StateNotifier<AsyncValue<List<Category>>> {
  final FetchCategoriesUseCase fetchCategoriesUseCase;

  CategoriesController(this.fetchCategoriesUseCase)
      : super(const AsyncValue.loading()) {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = fetchCategoriesUseCase.execute();
      state = AsyncValue.data(categories as List<Category>);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
