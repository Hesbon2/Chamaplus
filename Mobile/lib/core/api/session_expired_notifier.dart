import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global callback registry for session expiry events from the API layer.
class SessionExpiredNotifier {
  void Function()? _handler;

  void register(void Function() handler) {
    _handler = handler;
  }

  void notify() {
    _handler?.call();
  }
}

final sessionExpiredNotifierProvider = Provider<SessionExpiredNotifier>((ref) {
  return SessionExpiredNotifier();
});
