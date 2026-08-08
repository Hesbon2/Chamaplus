import 'package:chamaplus_mobile/core/cache/offline_cache_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OfflineCacheStore cache;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cache = OfflineCacheStore(await SharedPreferences.getInstance());
  });

  test('writes and reads fresh payloads', () async {
    final key = cache.cacheKey(method: 'GET', path: '/chamas/');
    await cache.write(key: key, data: {'count': 2, 'results': []});

    final read = cache.read(key) as Map?;
    expect(read?['count'], 2);
  });

  test('expires when past TTL unless allowExpired', () async {
    final key = cache.cacheKey(method: 'GET', path: '/notifications/');
    await cache.write(
      key: key,
      data: {'ok': true},
      ttl: const Duration(milliseconds: 1),
    );
    await Future<void>.delayed(const Duration(milliseconds: 5));

    expect(cache.read(key), isNull);
    expect(cache.read(key, allowExpired: true), isNotNull);
  });

  test('clearAll removes offline keys only', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', 'dark');
    final key = cache.cacheKey(method: 'GET', path: '/chamas/1/');
    await cache.write(key: key, data: {'id': '1'});

    await cache.clearAll();

    expect(cache.read(key, allowExpired: true), isNull);
    expect(prefs.getString('theme_mode'), 'dark');
  });
}
