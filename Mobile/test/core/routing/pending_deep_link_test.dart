import 'package:chamaplus_mobile/core/routing/pending_deep_link.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isEphemeralAuthLocation covers splash and auth entry points', () {
    expect(isEphemeralAuthLocation('/splash'), isTrue);
    expect(isEphemeralAuthLocation('/login'), isTrue);
    expect(isEphemeralAuthLocation('/register'), isTrue);
    expect(isEphemeralAuthLocation('/forgot-password'), isTrue);
    expect(isEphemeralAuthLocation('/chamas/c1/loans'), isFalse);
    expect(isEphemeralAuthLocation('/home'), isFalse);
  });

  test('pendingDeepLinkProvider stores and clears destinations', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(pendingDeepLinkProvider), isNull);
    container.read(pendingDeepLinkProvider.notifier).state = '/chamas/c1';
    expect(container.read(pendingDeepLinkProvider), '/chamas/c1');
    container.read(pendingDeepLinkProvider.notifier).state = null;
    expect(container.read(pendingDeepLinkProvider), isNull);
  });
}
