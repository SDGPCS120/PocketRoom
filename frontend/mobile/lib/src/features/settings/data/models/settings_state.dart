class SettingsState {
  final bool pushNotifications;
  final bool orderUpdates;
  final bool isLoggingOut;
  final String selectedLanguage;

  const SettingsState({
    this.pushNotifications = true,
    this.orderUpdates = true,
    this.isLoggingOut = false,
    this.selectedLanguage = 'English',
  });

  SettingsState copyWith({
    bool? pushNotifications,
    bool? orderUpdates,
    bool? isLoggingOut,
    String? selectedLanguage,
  }) {
    return SettingsState(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}
