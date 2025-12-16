import '../../session/application/session_controller.dart';

class UserAccount {
  const UserAccount({
    required this.email,
    required this.displayName,
    required this.password,
    required this.role,
  });

  final String email;
  final String displayName;

  /// Demo-only. Do NOT store plaintext passwords in production.
  final String password;

  final UserRole role;

  Map<String, Object?> toJson() => {
    'email': email,
    'displayName': displayName,
    'password': password,
    'role': role.name,
  };

  static UserAccount fromJson(Map<String, Object?> json) {
    final roleRaw = (json['role'] as String?) ?? 'customer';
    final role = roleRaw == 'admin' ? UserRole.admin : UserRole.customer;

    return UserAccount(
      email: ((json['email'] as String?) ?? '').trim(),
      displayName: ((json['displayName'] as String?) ?? '').trim(),
      password: (json['password'] as String?) ?? '',
      role: role,
    );
  }
}
