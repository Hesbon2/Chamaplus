import '../../domain/entities/dashboard.dart';

/// In-memory TTL cache for dashboard responses.
class DashboardCache {
  DashboardCache({this.ttl = const Duration(minutes: 2)});

  final Duration ttl;

  Dashboard? _data;
  DateTime? _fetchedAt;

  Dashboard? get() {
    if (_data == null || _fetchedAt == null) return null;
    if (DateTime.now().difference(_fetchedAt!) > ttl) {
      clear();
      return null;
    }
    return _data;
  }

  void put(Dashboard dashboard) {
    _data = dashboard;
    _fetchedAt = DateTime.now();
  }

  void clear() {
    _data = null;
    _fetchedAt = null;
  }
}
