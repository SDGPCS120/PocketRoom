/// Central configuration for the backend API.
///
/// For Android emulators, use `10.0.2.2` (which maps to the host's localhost).
/// For iOS simulators or physical devices on the same network, use the host's
/// local IP address (e.g., `192.168.x.x`).
class ApiConfig {
  ApiConfig._();

  /// USE NGROK for mobile phone testing (works everywhere)
  // static const String baseUrl = 'https://jagless-kristal-appliably.ngrok-free.dev';

  /// PRIMARY: Use 10.0.2.2 for Android Emulator (most common)
  // static const String baseUrl = 'http://10.0.2.2:8000';

  /// ALTERNATIVE: Local IP for physical mobile phone (must be on same Wi-Fi)
  static const String baseUrl = 'http://10.160.149.66:8000';
}
