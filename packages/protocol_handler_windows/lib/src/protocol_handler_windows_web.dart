import 'package:protocol_handler_windows/src/protocol_handler_windows_base.dart';

class ProtocolHandlerWindowsImpl extends ProtocolHandlerWindowsBase {
  ProtocolHandlerWindowsImpl() : super();

  static void registerWith() {
    // Web implementation does nothing.
  }

  Future<void> register(String scheme, {String? friendlyAppName}) async {
    // Web implementation does nothing.
  }
}
