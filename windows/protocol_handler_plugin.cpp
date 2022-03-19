#include "include/protocol_handler/protocol_handler_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <codecvt>
#include <map>
#include <memory>
#include <sstream>

namespace {

class ProtocolHandlerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  ProtocolHandlerPlugin(
      flutter::PluginRegistrarWindows* registrar,
      std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel);

  flutter::MethodChannel<flutter::EncodableValue>* channel() const {
    return channel_.get();
  }

  virtual ~ProtocolHandlerPlugin();

 private:
  flutter::PluginRegistrarWindows* registrar_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_ =
      nullptr;

  int32_t window_proc_id_ = -1;

  std::optional<LRESULT> HandleWindowProc(HWND hwnd,
                                          UINT message,
                                          WPARAM wparam,
                                          LPARAM lparam);

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void ProtocolHandlerPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<ProtocolHandlerPlugin>(
      registrar,
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "protocol_handler",
          &flutter::StandardMethodCodec::GetInstance()));
  plugin->channel()->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });
  registrar->AddPlugin(std::move(plugin));
}

ProtocolHandlerPlugin::ProtocolHandlerPlugin(
    flutter::PluginRegistrarWindows* registrar,
    std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel)
    : registrar_(registrar), channel_(std::move(channel)) {
  window_proc_id_ = registrar->RegisterTopLevelWindowProcDelegate(
      [this](HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
        return HandleWindowProc(hwnd, message, wparam, lparam);
      });
}

ProtocolHandlerPlugin::~ProtocolHandlerPlugin() {
  registrar_->UnregisterTopLevelWindowProcDelegate(window_proc_id_);
}

std::optional<LRESULT> ProtocolHandlerPlugin::HandleWindowProc(HWND hwnd,
                                                               UINT message,
                                                               WPARAM wparam,
                                                               LPARAM lparam) {
  switch (message) {
    case WM_COPYDATA:
      COPYDATASTRUCT* cds = {0};
      cds = (COPYDATASTRUCT*)lparam;

      if (cds->dwData == PROTOCOL_MSG_ID) {
        std::string url((char*)((LPCWSTR)cds->lpData));

        flutter::EncodableMap args = flutter::EncodableMap();
        args[flutter::EncodableValue("url")] =
            flutter::EncodableValue(url.c_str());

        channel_->InvokeMethod("onProtocolUrlReceived",
                               std::make_unique<flutter::EncodableValue>(args));
      }
      break;
  }
  return std::nullopt;
}

void ProtocolHandlerPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void ProtocolHandlerPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  ProtocolHandlerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

void DispatchToProtocolHandler(HWND hwnd) {
  int argc;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv == nullptr) {
    return;
  }

  std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
  std::string url = converter.to_bytes(argv[1]);
  ::LocalFree(argv);

  COPYDATASTRUCT cds = {0};
  cds.dwData = PROTOCOL_MSG_ID;
  cds.cbData = (DWORD)(strlen(url.c_str()) + 1);
  cds.lpData = (PVOID)url.c_str();

  SendMessage(hwnd, WM_COPYDATA, 0, (LPARAM)&cds);
}
