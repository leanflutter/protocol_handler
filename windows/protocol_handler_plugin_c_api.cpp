#include "include/protocol_handler/protocol_handler_plugin_c_api.h"

#include <windows.h>

#include <shellapi.h>

#include <string>
#include <vector>

// The receiving side is core/src/platform/windows/protocol_handler_windows.cpp;
// the window class, title rule and dwData below are its forwarding contract.

namespace {

constexpr wchar_t kReceiverClass[] = L"NativeAPI.ProtocolHandler";
constexpr ULONG_PTR kCopyDataUrl = 0x4E415055;

std::wstring ExecutablePath() {
  std::vector<wchar_t> buffer(MAX_PATH);
  for (;;) {
    DWORD length = GetModuleFileNameW(nullptr, buffer.data(), static_cast<DWORD>(buffer.size()));
    if (length == 0)
      return {};
    if (length < buffer.size())
      return std::wstring(buffer.data(), length);
    buffer.resize(buffer.size() * 2);
  }
}

// Same rule as core: a scheme of two or more characters, so "C:\x" is a path.
bool LooksLikeUrl(const std::wstring& value) {
  size_t colon = value.find(L':');
  if (colon == std::wstring::npos || colon < 2)
    return false;
  for (size_t i = 0; i < colon; ++i) {
    wchar_t c = value[i];
    bool alpha = (c >= L'a' && c <= L'z') || (c >= L'A' && c <= L'Z');
    bool other = (c >= L'0' && c <= L'9') || c == L'+' || c == L'-' || c == L'.';
    if (!alpha && (i == 0 || !other))
      return false;
  }
  return true;
}

std::string ToUtf8(const std::wstring& value) {
  int size = WideCharToMultiByte(CP_UTF8, 0, value.data(), static_cast<int>(value.size()),
                                 nullptr, 0, nullptr, nullptr);
  std::string result(size > 0 ? size : 0, '\0');
  if (size > 0)
    WideCharToMultiByte(CP_UTF8, 0, value.data(), static_cast<int>(value.size()), result.data(),
                        size, nullptr, nullptr);
  return result;
}

struct WindowSearch {
  DWORD process_id;
  HWND window;
};

BOOL CALLBACK FindMainWindow(HWND window, LPARAM lparam) {
  auto* search = reinterpret_cast<WindowSearch*>(lparam);
  DWORD process_id = 0;
  GetWindowThreadProcessId(window, &process_id);
  if (process_id == search->process_id && IsWindowVisible(window) &&
      GetWindow(window, GW_OWNER) == nullptr) {
    search->window = window;
    return FALSE;
  }
  return TRUE;
}

}  // namespace

void ProtocolHandlerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef /*registrar*/) {
  // Nothing to register: the Dart API is protocol_handler's ProtocolHandler, and core
  // reads the launch URL and receives forwarded ones on its own.
}

bool ProtocolHandlerForwardToRunningInstance(void) {
  int argc = 0;
  LPWSTR* argv = CommandLineToArgvW(GetCommandLineW(), &argc);
  if (!argv)
    return false;
  std::wstring url;
  for (int i = 1; i < argc && url.empty(); ++i) {
    if (LooksLikeUrl(argv[i]))
      url = argv[i];
  }
  LocalFree(argv);
  if (url.empty())
    return false;

  std::wstring title = ExecutablePath();
  CharLowerBuffW(title.data(), static_cast<DWORD>(title.size()));
  HWND receiver = FindWindowExW(HWND_MESSAGE, nullptr, kReceiverClass, title.c_str());
  if (!receiver)
    return false;

  DWORD process_id = 0;
  GetWindowThreadProcessId(receiver, &process_id);
  // This process was just started by the user, so it may hand the foreground on.
  AllowSetForegroundWindow(process_id);

  std::string payload = ToUtf8(url);
  COPYDATASTRUCT data{};
  data.dwData = kCopyDataUrl;
  data.cbData = static_cast<DWORD>(payload.size());
  data.lpData = payload.data();
  DWORD_PTR result = 0;
  if (!SendMessageTimeoutW(receiver, WM_COPYDATA, 0, reinterpret_cast<LPARAM>(&data),
                           SMTO_ABORTIFHUNG, 5000, &result) ||
      !result)
    return false;

  WindowSearch search{process_id, nullptr};
  EnumWindows(FindMainWindow, reinterpret_cast<LPARAM>(&search));
  if (search.window) {
    if (IsIconic(search.window))
      ShowWindow(search.window, SW_RESTORE);
    SetForegroundWindow(search.window);
  }
  return true;
}
