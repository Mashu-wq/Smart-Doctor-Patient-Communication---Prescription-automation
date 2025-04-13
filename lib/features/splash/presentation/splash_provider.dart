import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisafe/features/splash/data/repositories/cache_repository.dart';
import 'package:medisafe/features/splash/domain/usecases/read_cache_usecases.dart';

import 'package:shared_preferences/shared_preferences.dart';

// FutureProvider for the splash logic
final splashProvider = FutureProvider<int?>((ref) async {
  final readCacheUseCase = await ref.watch(readCacheUseCaseProvider.future);
  return await readCacheUseCase.execute('password');
});

// FutureProvider for ReadCacheUseCase initialization
final readCacheUseCaseProvider = FutureProvider<ReadCacheUseCase>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final cacheRepository = CacheRepository(prefs);
  return ReadCacheUseCase(cacheRepository);
});
