import 'package:shared_preferences/shared_preferences.dart';

class CacheRepository {
  final SharedPreferences prefs;

  CacheRepository(this.prefs);

  Future<int?> readCache(String key) async {
    return prefs.getInt(key);
  }
}
