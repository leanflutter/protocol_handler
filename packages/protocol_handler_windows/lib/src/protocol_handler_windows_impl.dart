import 'package:protocol_handler_platform_interface/protocol_handler_platform_interface.dart';

import 'protocol_handler_windows_stub.dart'
    if (dart.library.io) 'protocol_handler_windows_io.dart'
    if (dart.library.html) 'protocol_handler_windows_web.dart';

class ProtocolHandlerWindows extends MethodChannelProtocolHandler {
  final ProtocolHandlerWindowsImpl _impl;

  ProtocolHandlerWindows() : _impl = ProtocolHandlerWindowsImpl();

  static void registerWith() {
    ProtocolHandlerPlatform.instance = ProtocolHandlerWindowsImpl();
  }

  Future<void> register(String scheme, {String? friendlyAppName}) async {
    return await _impl.register(
      scheme,
      friendlyAppName: friendlyAppName,
    );
  }
}
