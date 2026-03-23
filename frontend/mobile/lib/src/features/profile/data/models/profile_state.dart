class ProfileState {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String role;
  final bool isLoading;
  final bool isAnonymousUser;

  const ProfileState({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.role = 'customer',
    this.isLoading = true,
    this.isAnonymousUser = false,
  });

  ProfileState copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? role,
    bool? isLoading,
    bool? isAnonymousUser,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      isAnonymousUser: isAnonymousUser ?? this.isAnonymousUser,
    );
  }
}
