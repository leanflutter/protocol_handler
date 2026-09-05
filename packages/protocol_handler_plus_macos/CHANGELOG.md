## 2.0.1

* Fix `pluginClass` in pubspec.yaml, which was set to `ProtocolHandlerPlusPlusMacosPlugin` instead of the actual Swift class `ProtocolHandlerPlusMacosPlugin`. The mismatch made `flutter build macos`/`flutter run -d macos` fail with `cannot find 'ProtocolHandlerPlusPlusMacosPlugin' in scope` in the generated plugin registrant.
* Add Swift Package Manager support (`macos/protocol_handler_plus_macos/Package.swift`), matching the layout Flutter expects since 3.24. This clears the `does not support Swift Package Manager for macos` build warning. CocoaPods integration (the `.podspec`) is kept for apps that haven't migrated to SPM yet.

## 2.0.0

* **BREAKING**: The method and event channel names changed from `dev.stan-at-work.plugins/...` to `dev.stan_at_work.plugins/protocol_handler_plus` and `dev.stan_at_work.plugins/protocol_handler_plus_event`.
* Bump `protocol_handler_plus_platform_interface` to `^2.0.0`.

## 1.0.2

* Update version and metadata of the repository

## 1.0.1

* Update README.md

## 1.0.0

* First release.