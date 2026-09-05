## 2.0.1

* Fix macOS build failure (`cannot find 'ProtocolHandlerPlusPlusMacosPlugin' in scope`) caused by a `pluginClass` typo in `protocol_handler_plus_macos`.
* Bump all platform implementation dependencies to `^2.0.1`.

## 2.0.0

* **BREAKING**: Renamed the plugin identifier from `dev.stan-at-work` to `dev.stan_at_work`. Hyphens are not valid in Java package names, so the method channel (`dev.stan_at_work.plugins/protocol_handler_plus`), the event channel (`dev.stan_at_work.plugins/protocol_handler_plus_event`) and the Android package all changed. Apps that reference the old identifier (e.g. the `package` attribute in `AndroidManifest.xml`) must be updated.
* Bump all platform implementation dependencies to `^2.0.0`.
* Update README.md to use the new `dev.stan_at_work` identifier.
* Remove the stale upstream copyright line from LICENSE.
* Update the example app (Android namespace/application id, macOS bundle identifier and copyright, Windows company name and copyright) to the new identifier.

## 1.0.2+1

* Update metadata in pubspec.yaml

## 1.0.2

* Update version and metadata of the repository

## 1.0.1

* Update README.md

## 1.0.0

* First release, that works with flutter 3.47.0 and is constrainted to: sdk: ">=3.10.0 <4.0.0"