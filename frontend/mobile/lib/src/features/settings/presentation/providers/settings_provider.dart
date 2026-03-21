import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/settings_state.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void togglePushNotifications(bool value) {
    state = state.copyWith(pushNotifications: value);
  }

  void toggleOrderUpdates(bool value) {
    state = state.copyWith(orderUpdates: value);
  }

  void setLanguage(String value) {
    state = state.copyWith(selectedLanguage: value);
  }

  Future<void> launchPocketRoom() async {
    final uri = Uri.parse('https://www.pocketroom.lk');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> logout() async {
    if (state.isLoggingOut) return false;
    
    state = state.copyWith(isLoggingOut: true);
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.signInAnonymously();
      // Note: We don't flip isLoggingOut back to false on success, 
      // preventing UI flicker during the navigation transition away from the page.
      return true;
    } catch (_) {
      state = state.copyWith(isLoggingOut: false);
      return false;
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
