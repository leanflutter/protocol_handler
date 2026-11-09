/// @docImport 'protocol_handler.dart';
library;

/// Receives the URLs [ProtocolHandler] delivers while the application runs.
///
/// Mix it into a `State` and register it with [ProtocolHandler.addListener]
/// in `initState`; remove it with [ProtocolHandler.removeListener] in
/// `dispose`.
abstract mixin class ProtocolListener {
  /// Called for every URL of one of the application's schemes delivered while
  /// it is running. The URL that launched the application is
  /// [ProtocolHandler.getInitialUrl] instead.
  void onProtocolUrlReceived(String url) {}
}
