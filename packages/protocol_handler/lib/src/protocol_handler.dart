import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:protocol_handler_platform_interface/protocol_handler_platform_interface.dart';

class ProtocolHandler {
  ProtocolHandler._();

  /// The shared instance of [ProtocolHandler].
  static final ProtocolHandler instance = ProtocolHandler._();

  ProtocolHandlerPlatform get _platform => ProtocolHandlerPlatform.instance;

  bool _isListening = false;
  final ObserverList<ProtocolListener> _listeners =
      ObserverList<ProtocolListener>();

  void _startListening() {
    if (_isListening) return;
    _isListening = true;
    _platform.onUrlReceived.listen((String? url) {
      if (url == null) {
        return;
      }
      for (final ProtocolListener listener in listeners) {
        if (!_listeners.contains(listener)) {
          return;
        }
        listener.onProtocolUrlReceived(url);
      }
    });
  }

  void _stopListening() {
    if (!_isListening) return;
    _isListening = false;
  }

  List<ProtocolListener> get listeners {
    final List<ProtocolListener> localListeners =
        List<ProtocolListener>.from(_listeners);
    return localListeners;
  }

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void addListener(ProtocolListener listener) {
    _listeners.add(listener);
    if (_listeners.isNotEmpty && !_isListening) {
      _startListening();
    }
  }

  void removeListener(ProtocolListener listener) {
    _listeners.remove(listener);
    if (_listeners.isEmpty && _isListening) {
      _stopListening();
    }
  }

  /// A broadcast stream of incoming protocol urls.
  Stream<String?> get onUrlReceived => _platform.onUrlReceived;

  /// Register a custom protocol
  ///
  /// [scheme] is the custom protocol scheme, e.g. `myapp`
  Future<void> register(String scheme) {
    return _platform.register(scheme);
  }

  /// If the app launch was triggered by an protocol, it will give the link url,
  /// otherwise it will give null.
  Future<String?> getInitialUrl() {
    return _platform.getInitialUrl();
  }
}

final protocolHandler = ProtocolHandler.instance;
