/// Authenticated user entity.
class User {
  const User({
    required this.id,
    required this.phoneNumber,
    this.email,
    this.firstName,
    this.lastName,
    required this.isStaff,
    required this.dateJoined,
    this.lastLogin,
  });

  final String id;
  final String phoneNumber;
  final String? email;
  final String? firstName;
  final String? lastName;
  final bool isStaff;
  final DateTime dateJoined;
  final DateTime? lastLogin;

  String get displayName {
    final parts = [firstName, lastName].where((p) => p != null && p.isNotEmpty);
    if (parts.isNotEmpty) {
      return parts.join(' ');
    }
    return phoneNumber;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
