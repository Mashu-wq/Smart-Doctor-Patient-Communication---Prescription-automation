import 'package:medisafe/features/splash/data/repositories/cache_repository.dart';

class ReadCacheUseCase {
  final CacheRepository cacheRepository;

  ReadCacheUseCase(this.cacheRepository);

  Future<int?> execute(String key) async {
    return cacheRepository.readCache(key);
  }
}
