import 'dart:io';

import 'protocol_registrar_impl_android.dart';
import 'protocol_registrar_impl_ios.dart';
import 'protocol_registrar_impl_macos.dart';
import 'protocol_registrar_impl_windows.dart';

class ProtocolRegistrar {
  /// The shared instance of [ProtocolRegistrar].
  static ProtocolRegistrar get instance {
    if (Platform.isAndroid) return ProtocolRegistrarImplAndroid.instance;
    if (Platform.isIOS) return ProtocolRegistrarImplIOS.instance;
    if (Platform.isMacOS) return ProtocolRegistrarImplMacOS.instance;
    if (Platform.isWindows) return ProtocolRegistrarImplWindows.instance;
    return ProtocolRegistrar();
  }

  Future<void> register(String scheme) async {
    throw UnimplementedError();
  }
}

final protocolRegistrar = ProtocolRegistrar.instance;
