import Cocoa
import FlutterMacOS

public class ProtocolHandlerPlugin: NSObject, FlutterPlugin  {
    private var channel: FlutterMethodChannel!
    
    private var _initialUrl: String?
    
    override init(){
        super.init();
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleURLEvent(_:with:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "protocol_handler", binaryMessenger: registrar.messenger)
        let instance = ProtocolHandlerPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    @objc
    private func handleURLEvent(_ event: NSAppleEventDescriptor, with replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue else { return }
        if (_initialUrl == nil) {
            _initialUrl = urlString
        }
        
        let args: NSDictionary = [
            "url": urlString,
        ]
        channel.invokeMethod("onProtocolUrlReceived", arguments: args, result: nil)
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
