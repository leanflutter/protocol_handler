#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint protocol_handler.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'protocol_handler'
  s.version          = '0.3.0'
  s.summary          = 'Delivers deep links to nativeapi before Dart starts.'
  s.description      = <<-DESC
Captures launch and incoming custom protocol URLs and hands them to the nativeapi core library.
                       DESC
  s.homepage         = 'https://github.com/leanflutter/protocol_handler'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'LiJianying' => 'lijy91@foxmail.com' }

  s.source           = { :path => '.' }
  s.source_files = 'protocol_handler/Sources/protocol_handler/**/*'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'protocol_handler_privacy' => ['protocol_handler/Sources/protocol_handler/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
