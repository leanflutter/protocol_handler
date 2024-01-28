import Cocoa
import FlutterMacOS

public class ProtocolHandlerMacosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, FlutterAppLifecycleDelegate {
    private var _eventSink: FlutterEventSink?
    
    private var _initialUrl: String?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "dev.leanflutter.plugins/protocol_handler", binaryMessenger: registrar.messenger)
        let instance = ProtocolHandlerMacosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
        
        let eventChannel = FlutterEventChannel(name: "dev.leanflutter.plugins/protocol_handler_event", binaryMessenger: registrar.messenger)
        eventChannel.setStreamHandler(instance)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self._eventSink = events
        return nil;
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self._eventSink = nil
        return nil
    }
    
    public func handleWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:with:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }
    
    @objc
    public func handleURLEvent(_ event: NSAppleEventDescriptor, with replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue else { return }
        if (_initialUrl == nil) {
            _initialUrl = urlString
        }
        guard let eventSink = self._eventSink else {
            return
        }
        eventSink(urlString)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getInitialUrl":
            result(self._initialUrl ?? "");
            break;
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
