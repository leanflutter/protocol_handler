import Flutter
import UIKit

public class ProtocolHandlerIosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var _eventSink: FlutterEventSink?
    
    private var _initialUrl: String?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "dev.leanflutter.plugins/protocol_handler", binaryMessenger: registrar.messenger())
        let instance = ProtocolHandlerIosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
        let eventChannel = FlutterEventChannel(name: "dev.leanflutter.plugins/protocol_handler_event", binaryMessenger: registrar.messenger())
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
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getInitialUrl":
            result(self._initialUrl ?? "");
            break;
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        let url: Any? = launchOptions[UIApplication.LaunchOptionsKey.url];
        if (url != nil) {
            self._initialUrl = (url as! URL).absoluteString
        }
        return true
    }
    
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let eventSink = self._eventSink else {
            return false
        }
        eventSink(url.absoluteString)
        return false
    }
}
