# protocol_handler_platform_interface

[![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/protocol_handler_platform_interface.svg
[pub-url]: https://pub.dev/packages/protocol_handler_platform_interface

A common platform interface for the [protocol_handler](https://pub.dev/packages/protocol_handler) plugin.

## Usage

To implement a new platform-specific implementation of protocol_handler, extend `ProtocolHandlerPlatform` with an implementation that performs the platform-specific behavior, and when you register your plugin, set the default `ProtocolHandlerPlatform` by calling `ProtocolHandlerPlatform.instance = MyPlatformProtocolHandler()`.

## License

[MIT](./LICENSE)
