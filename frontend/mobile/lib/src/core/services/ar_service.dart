import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final arServiceProvider = Provider((ref) => ArService());

class ArService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.pocketroom/unity_ar',
  );

  Future<bool> launchExternalArApp() async {
    try {
      final bool success = await _channel.invokeMethod<bool>('launchExternalArApp') ?? false;
      return success;
    } on PlatformException catch (e) {
      // Return false so we can handle the error in UI if needed
      return false;
    }
  }
}
