import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nativeapi/nativeapi.dart' as nativeapi;

import 'protocol_listener.dart';

/// Registers custom protocols and delivers the URLs that open the app.
///
/// Backed by nativeapi's `ProtocolHandler`. The plugin's native part captures
/// URLs that arrive before Dart runs, and nativeapi queues URLs that arrive
/// while nothing listens, so a listener added in `initState` still receives a
/// link that opened the app moments earlier.
class ProtocolHandler {
  ProtocolHandler._();

  /// The shared instance of [ProtocolHandler].
  static final ProtocolHandler instance = ProtocolHandler._();

  nativeapi.ProtocolHandler get _native => nativeapi.ProtocolHandler.instance;

  final ObserverList<ProtocolListener> _listeners =
      ObserverList<ProtocolListener>();
  StreamSubscription<String?>? _listenerSubscription;

  late final StreamController<String?> _urls =
      StreamController<String?>.broadcast(
        onListen: _startNative,
        onCancel: _stopNative,
      );
  nativeapi.ListenerId? _nativeListener;

  void _startNative() {
    _nativeListener ??= _native.addListener((event) {
      final url = event is nativeapi.ProtocolUrlReceivedEvent
          ? event.url
          : null;
      if (url != null && url.isNotEmpty) {
        _urls.add(url);
      }
    });
  }

  void _stopNative() {
    final id = _nativeListener;
    if (id != null) {
      _native.removeListener(id);
      _nativeListener = null;
    }
  }

  void _notifyListeners(String? url) {
    if (url == null) return;
    for (final listener in listeners) {
      if (_listeners.contains(listener)) {
        listener.onProtocolUrlReceived(url);
      }
    }
  }

  /// A snapshot of the registered listeners.
  List<ProtocolListener> get listeners => List<ProtocolListener>.of(_listeners);

  /// Whether any listener is registered.
  bool get hasListeners => _listeners.isNotEmpty;

  /// Starts calling [ProtocolListener.onProtocolUrlReceived] on [listener].
  void addListener(ProtocolListener listener) {
    _listeners.add(listener);
    _listenerSubscription ??= onUrlReceived.listen(_notifyListeners);
  }

  /// Stops calling [listener]. Unknown listeners are ignored.
  void removeListener(ProtocolListener listener) {
    _listeners.remove(listener);
    if (_listeners.isEmpty) {
      unawaited(_listenerSubscription?.cancel());
      _listenerSubscription = null;
    }
  }

  /// A broadcast stream of the URLs delivered while the application runs.
  ///
  /// URLs that arrived while nothing listened (neither this stream nor a
  /// [ProtocolListener]) are delivered to the first subscriber. Never emits
  /// null; the type is nullable for compatibility with 0.2.
  Stream<String?> get onUrlReceived => _urls.stream;

  /// Registers this application as the handler of [scheme], e.g. `myapp`.
  ///
  /// On Windows this writes the registration for the current user (an MSIX
  /// package declares it in its manifest instead and gets false). On Android,
  /// iOS and macOS the scheme is declared in the app package; there it
  /// completes with whether the package declares [scheme].
  Future<bool> register(String scheme) async => _native.register(scheme);

  /// The URL that launched the application, or null when it was not launched
  /// by one.
  ///
  /// A launch URL the system delivers after this returned null is also
  /// delivered to [onUrlReceived] and the listeners.
  Future<String?> getInitialUrl() async => _native.getInitialUrl();
}

/// The shared [ProtocolHandler].
final protocolHandler = ProtocolHandler.instance;
