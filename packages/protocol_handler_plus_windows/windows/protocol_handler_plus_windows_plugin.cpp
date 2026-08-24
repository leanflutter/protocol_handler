#include "include/protocol_handler_plus_windows/protocol_handler_plus_windows_plugin_c_api.h"
#include "protocol_handler_plus_windows_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <codecvt>
#include <map>
#include <memory>
#include <sstream>

namespace protocol_handler_plus_windows {

// static
void ProtocolHandlerPlusWindowsPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "dev.stan_at_work.plugins/protocol_handler_plus",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<ProtocolHandlerPlusWindowsPlugin>(registrar);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  auto event_channel =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          registrar->messenger(),
          "dev.stan_at_work.plugins/protocol_handler_plus_event",
          &flutter::StandardMethodCodec::GetInstance());
  auto streamHandler = std::make_unique<flutter::StreamHandlerFunctions<>>(
      [plugin_pointer = plugin.get()](
          const flutter::EncodableValue* arguments,
          std::unique_ptr<flutter::EventSink<>>&& events)
          -> std::unique_ptr<flutter::StreamHandlerError<>> {
        return plugin_pointer->OnListen(arguments, std::move(events));
      },
      [plugin_pointer = plugin.get()](const flutter::EncodableValue* arguments)
          -> std::unique_ptr<flutter::StreamHandlerError<>> {
        return plugin_pointer->OnCancel(arguments);
      });
  event_channel->SetStreamHandler(std::move(streamHandler));

  registrar->AddPlugin(std::move(plugin));
}

ProtocolHandlerPlusWindowsPlugin::ProtocolHandlerPlusWindowsPlugin(
    flutter::PluginRegistrarWindows* registrar) {
  window_proc_id_ = registrar->RegisterTopLevelWindowProcDelegate(
      [this](HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
        return HandleWindowProc(hwnd, message, wparam, lparam);
      });
}

ProtocolHandlerPlusWindowsPlugin::~ProtocolHandlerPlusWindowsPlugin() {}

std::optional<LRESULT> ProtocolHandlerPlusWindowsPlugin::HandleWindowProc(
    HWND hwnd,
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
        if (event_sink_) {
          event_sink_->Success(flutter::EncodableValue(url.c_str()));
        }
      }
      break;
  }
  return std::nullopt;
}

std::string ProtocolHandlerPlusWindowsPlugin::GetInitialUrl() {
  int argc;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv == nullptr || argc < 2) {
    return "";
  }

  std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
  std::string url = converter.to_bytes(argv[1]);
  ::LocalFree(argv);
  return url;
}

void ProtocolHandlerPlusWindowsPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getInitialUrl") == 0) {
    std::string value = GetInitialUrl();
    result->Success(flutter::EncodableValue(value.c_str()));
  } else {
    result->NotImplemented();
  }
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
ProtocolHandlerPlusWindowsPlugin::OnListenInternal(
    const flutter::EncodableValue* arguments,
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
  event_sink_ = std::move(events);
  return nullptr;
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
ProtocolHandlerPlusWindowsPlugin::OnCancelInternal(
    const flutter::EncodableValue* arguments) {
  event_sink_ = nullptr;
  return nullptr;
}

}  // namespace protocol_handler_plus_windows
