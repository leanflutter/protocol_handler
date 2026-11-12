import 'package:flutter_test/flutter_test.dart';
import 'package:protocol_handler/protocol_handler.dart';

class _Listener with ProtocolListener {
  final List<String> urls = [];

  @override
  void onProtocolUrlReceived(String url) => urls.add(url);
}

void main() {
  test('a test process was not launched by a URL', () async {
    expect(await protocolHandler.getInitialUrl(), isNull);
  });

  test('listeners can be added, inspected and removed', () {
    final a = _Listener();
    final b = _Listener();
    expect(protocolHandler.hasListeners, isFalse);

    protocolHandler.addListener(a);
    protocolHandler.addListener(b);
    expect(protocolHandler.hasListeners, isTrue);
    expect(protocolHandler.listeners, [a, b]);

    // The list is a snapshot.
    protocolHandler.listeners.clear();
    expect(protocolHandler.listeners, hasLength(2));

    protocolHandler.removeListener(a);
    expect(protocolHandler.listeners, [b]);
    protocolHandler.removeListener(a);
    protocolHandler.removeListener(b);
    expect(protocolHandler.hasListeners, isFalse);
  });

  test('invalid schemes are rejected', () async {
    for (final scheme in ['', '1app', 'my app', 'app:']) {
      expect(await protocolHandler.register(scheme), isFalse, reason: scheme);
    }
  });
}
