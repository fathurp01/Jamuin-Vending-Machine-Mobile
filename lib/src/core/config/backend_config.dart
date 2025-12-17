final class BackendConfig {
  BackendConfig._();

  /// Backend base URL.
  ///
  /// Android emulator: http://10.0.2.2:3000
  /// Physical device: http://YOUR_PC_IP:3000
  static const String baseUrl = 'http://10.0.2.2:3000';

  static const String platform = 'mobile';
}
