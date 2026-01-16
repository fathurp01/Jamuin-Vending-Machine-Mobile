final class BackendConfig {
  BackendConfig._();

  /// Backend base URL.
  ///
  /// Android emulator: http://10.0.2.2:3000
  /// Physical device: http://YOUR_PC_IP:3000
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://icicled-unmischievously-shayna.ngrok-free.dev',
  );

  static const String platform = 'mobile';
}
