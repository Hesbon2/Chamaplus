import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';

/// Disk-backed JSON cache for GET responses (offline / stale fallback).
///
/// Not for secrets — never store tokens or passwords here.
class OfflineCacheStore {
  OfflineCacheStore(this._prefs);

  final SharedPreferences _prefs;

  static const String keyPrefix = 'offline_cache_v1:';
  static const Duration defaultTtl = Duration(hours: 12);

  static Future<OfflineCacheStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return OfflineCacheStore(prefs);
  }

  String cacheKey({
    required String method,
    required String path,
    Map<String, dynamic>? queryParameters,
  }) {
    final query = _stableQuery(queryParameters);
    return '$keyPrefix${method.toUpperCase()}:$path?$query';
  }

  Future<void> write({
    required String key,
    required Object? data,
    Duration? ttl,
  }) async {
    try {
      final envelope = <String, dynamic>{
        'savedAt': DateTime.now().toIso8601String(),
        'ttlMs': (ttl ?? defaultTtl).inMilliseconds,
        'data': data,
      };
      await _prefs.setString(key, jsonEncode(envelope));
    } catch (error, stackTrace) {
      AppLogger.error('Offline cache write failed', error, stackTrace);
    }
  }

  /// Returns cached payload when present and not past [maxAge] (if provided).
  ///
  /// When [allowExpired] is true, stale entries are still returned (offline mode).
  Object? read(
    String key, {
    Duration? maxAge,
    bool allowExpired = false,
  }) {
    try {
      final raw = _prefs.getString(key);
      if (raw == null || raw.isEmpty) return null;

      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final map = Map<String, dynamic>.from(decoded);
      final savedAtRaw = map['savedAt'] as String?;
      final ttlMs = map['ttlMs'] as int? ?? defaultTtl.inMilliseconds;
      final savedAt =
          savedAtRaw == null ? null : DateTime.tryParse(savedAtRaw);
      if (savedAt == null) return null;

      final age = DateTime.now().difference(savedAt);
      final effectiveMax = maxAge ?? Duration(milliseconds: ttlMs);
      if (age > effectiveMax && !allowExpired) {
        return null;
      }

      return map['data'];
    } catch (error, stackTrace) {
      AppLogger.error('Offline cache read failed', error, stackTrace);
      return null;
    }
  }

  Future<void> invalidate(String key) async {
    await _prefs.remove(key);
  }

  /// Drops keys whose path contains [pathFragment] (e.g. `/chamas/abc/`).
  Future<void> invalidatePathContaining(String pathFragment) async {
    final keys = _prefs.getKeys().where(
          (k) => k.startsWith(keyPrefix) && k.contains(pathFragment),
        );
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  Future<void> clearAll() async {
    final keys =
        _prefs.getKeys().where((k) => k.startsWith(keyPrefix)).toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  String _stableQuery(Map<String, dynamic>? queryParameters) {
    if (queryParameters == null || queryParameters.isEmpty) return '';
    final entries = queryParameters.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => '${e.key}=${e.value}').join('&');
  }
}

/// Must be overridden in [main] with [OfflineCacheStore.create].
final offlineCacheStoreProvider = Provider<OfflineCacheStore>((ref) {
  throw StateError(
    'offlineCacheStoreProvider must be overridden in main()',
  );
});
