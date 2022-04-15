import 'protocol_registrar.dart';

class ProtocolRegistrarImplIOS extends ProtocolRegistrar {
  ProtocolRegistrarImplIOS._();

  /// The shared instance of [ProtocolRegistrarImplIOS].
  static final ProtocolRegistrarImplIOS instance = ProtocolRegistrarImplIOS._();

  @override
  Future<void> register(String protocol) async {
    // Skip
  }
}
