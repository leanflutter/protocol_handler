import 'package:protocol_handler/src/protocol_registrar.dart';

class ProtocolRegistrarImplAndroid extends ProtocolRegistrar {
  ProtocolRegistrarImplAndroid._();

  /// The shared instance of [ProtocolRegistrarImplAndroid].
  static final ProtocolRegistrarImplAndroid instance =
      ProtocolRegistrarImplAndroid._();

  @override
  Future<void> register(String scheme) async {
    // Skip
  }
}
