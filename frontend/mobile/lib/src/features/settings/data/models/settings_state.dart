class SettingsState {
  final bool pushNotifications;
  final bool orderUpdates;
  final bool isLoggingOut;
  final bool isDeletingAccount;
  final String selectedLanguage;

  const SettingsState({
    this.pushNotifications = true,
    this.orderUpdates = true,
    this.isLoggingOut = false,
    this.isDeletingAccount = false,
    this.selectedLanguage = 'English',
  });

  SettingsState copyWith({
    bool? pushNotifications,
    bool? orderUpdates,
    bool? isLoggingOut,
    bool? isDeletingAccount,
    String? selectedLanguage,
  }) {
    return SettingsState(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      isDeletingAccount: isDeletingAccount ?? this.isDeletingAccount,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}
