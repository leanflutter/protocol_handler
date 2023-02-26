import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:protocol_handler/src/protocol_listener.dart';
import 'package:protocol_handler/src/protocol_registrar.dart';

class ProtocolHandler {
  ProtocolHandler._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  /// The shared instance of [ProtocolHandler].
  static final ProtocolHandler instance = ProtocolHandler._();

  final MethodChannel _channel = const MethodChannel('protocol_handler');

  final ObserverList<ProtocolListener> _listeners =
      ObserverList<ProtocolListener>();

  Future<void> _methodCallHandler(MethodCall call) async {
    for (final ProtocolListener listener in listeners) {
      if (!_listeners.contains(listener)) {
        return;
      }

      if (call.method == 'onProtocolUrlReceived') {
        listener.onProtocolUrlReceived(call.arguments['url']);
      } else {
        throw UnimplementedError();
      }
    }
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
  }

  void removeListener(ProtocolListener listener) {
    _listeners.remove(listener);
  }

  /// Register a custom protocol
  Future<void> register(String scheme) {
    return protocolRegistrar.register(scheme);
  }

  /// If the app launch was triggered by an protocol, it will give the link url, otherwise it will give null.
  Future<String?> getInitialUrl() async {
    String initialUrl = await _channel.invokeMethod('getInitialUrl');
    return initialUrl.isEmpty ? null : initialUrl;
  }
}

final protocolHandler = ProtocolHandler.instance;
