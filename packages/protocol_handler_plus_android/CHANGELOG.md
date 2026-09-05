## 2.0.1

* Republish alongside the `protocol_handler_plus_macos` build fix. No functional changes.

## 2.0.0

* **BREAKING**: Renamed the Java package from `dev.stan-at-work.plugins.protocol_handler_plus` to `dev.stan_at_work.plugins.protocol_handler_plus`, since hyphens are not valid in Java package names. This also updates the Gradle `group` and `namespace`, the `package` attribute in `AndroidManifest.xml` and the `pluginClass` package registered in pubspec.yaml.
* **BREAKING**: The method and event channel names changed to `dev.stan_at_work.plugins/protocol_handler_plus` and `dev.stan_at_work.plugins/protocol_handler_plus_event`.
* Move the plugin and test sources into the matching `dev/stan_at_work/plugins/protocol_handler_plus/` directory, so the source layout matches the declared package again.
* Bump `protocol_handler_plus_platform_interface` to `^2.0.0`.

## 1.0.2

* Update version and metadata of the repository

## 1.0.1

* Update README.md

## 1.0.0

* First release.