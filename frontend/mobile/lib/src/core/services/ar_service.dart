import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final arServiceProvider = Provider((ref) => ArService());

class ArService {
  Future<bool> launchExternalArApp() async {
    try {
      await LaunchApp.openApp(
        androidPackageName: 'com.example.please_work',
        openStore: true,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
