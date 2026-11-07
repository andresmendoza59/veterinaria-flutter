enum UserRole {
  member('member'),
  coordinator('coordinator'),
  finance('finance');

  final String value;

  const UserRole(this.value);

  static UserRole fromValue(String? value) {
    for (final role in UserRole.values) {
      if (role.value == value) return role;
    }
    return UserRole.member;
  }

  String get label {
    switch (this) {
      case UserRole.member:
        return 'Miembro';
      case UserRole.coordinator:
        return 'Coordinador';
      case UserRole.finance:
        return 'Responsable de presupuesto';
    }
  }
}
