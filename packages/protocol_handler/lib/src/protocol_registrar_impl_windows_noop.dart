import 'package:protocol_handler/src/protocol_registrar.dart';

class ProtocolRegistrarImplWindows extends ProtocolRegistrar {
  ProtocolRegistrarImplWindows._();

  /// The shared instance of [ProtocolRegistrarImplWindows].
  static final ProtocolRegistrarImplWindows instance =
      ProtocolRegistrarImplWindows._();

  @override
  Future<void> register(String scheme) async {}
}
