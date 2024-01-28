import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:protocol_handler_platform_interface/src/protocol_handler_method_channel.dart';

abstract class ProtocolHandlerPlatform extends PlatformInterface {
  /// Constructs a ProtocolHandlerPlatform.
  ProtocolHandlerPlatform() : super(token: _token);

  static final Object _token = Object();

  static ProtocolHandlerPlatform _instance = MethodChannelProtocolHandler();

  /// The default instance of [ProtocolHandlerPlatform] to use.
  ///
  /// Defaults to [MethodChannelProtocolHandler].
  static ProtocolHandlerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ProtocolHandlerPlatform] when
  /// they register themselves.
  static set instance(ProtocolHandlerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<String?> get onUrlReceived;

  /// Register the protocol scheme.
  Future<void> register(String scheme) {
    throw UnimplementedError('register() has not been implemented.');
  }

  /// If the app launch was triggered by an protocol, it will give the link url,
  /// otherwise it will give null.
  Future<String?> getInitialUrl() {
    throw UnimplementedError('getInitialUrl() has not been implemented.');
  }
}
