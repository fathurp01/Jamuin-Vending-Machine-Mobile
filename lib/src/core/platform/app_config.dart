import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppConfig {
  AppConfig._();

  static const MethodChannel _channel = MethodChannel(
    'com.example.jamuin/app_config',
  );

  /// Returns the Google Maps Android API key from AndroidManifest meta-data.
  ///
  /// On non-Android platforms (or if the channel isn't implemented), returns null.
  static Future<String?> getAndroidMapsApiKey() async {
    if (defaultTargetPlatform != TargetPlatform.android) return null;

    try {
      final result = await _channel.invokeMethod<String>('getMapsApiKey');
      return result;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
