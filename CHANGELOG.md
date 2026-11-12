## 0.3.0

* **Breaking:** rebuilt on nativeapi's protocol handler. Requires Flutter 3.50 / Dart 3.14 and nativeapi 0.6.0. The package is now a single plugin: `protocol_handler_android`, `_ios`, `_macos`, `_windows` and `_platform_interface` are gone.
* **Breaking:** `register()` completes with a `bool`.
* The rest of the Dart API is unchanged: `register`, `getInitialUrl`, `onUrlReceived`, `addListener` / `removeListener`, `listeners` and `hasListeners`.
* URLs that arrive while nothing listens are queued and delivered to the first listener, and a launch URL delivered after `getInitialUrl()` returned null reaches the listeners too.
* Windows: call `ProtocolHandlerForwardToRunningInstance()` first thing in `wWinMain`, so a second instance forwards its URL to the running one and exits.

## 0.2.0

* feat: Convert to federated plugin
* fix: Fix iOS platform handler issue #7

## 0.1.6

* fix: macos 3.16 plugin register issue #13

## 0.1.5

* Make sure the web project build

## 0.1.4

* bump win32_registry to 1.0.2
* Expose ProtocolHandlerPlugin so it's possible to call 'handleEventURL' for multiple plugins #6

## 0.1.3

* [windows] fix startup crash when argc is 1 #4

## 0.1.2

* Support android & ios platform.

## 0.1.1

* [macos & windows] Implement `getInitialUrl` metnod.

## 0.1.0

* First release.
