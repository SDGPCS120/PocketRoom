/// Central configuration for the backend API.
///
/// For Android emulators, use `10.0.2.2` (which maps to the host's localhost).
/// For iOS simulators or physical devices on the same network, use the host's
/// local IP address (e.g., `192.168.x.x`).
class ApiConfig {
  ApiConfig._();

  /// Change this to your machine's IP if testing on a physical device.
  static const String baseUrl = 'http://10.0.2.2:3000';
}
