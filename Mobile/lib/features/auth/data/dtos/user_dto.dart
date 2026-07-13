import '../../domain/entities/user.dart';

/// User profile payload from `/users/me/`.
class UserDto {
  const UserDto({
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

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      isStaff: json['is_staff'] as bool? ?? false,
      dateJoined: DateTime.parse(json['date_joined'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
    );
  }

  User toEntity() {
    return User(
      id: id,
      phoneNumber: phoneNumber,
      email: email,
      firstName: firstName,
      lastName: lastName,
      isStaff: isStaff,
      dateJoined: dateJoined,
      lastLogin: lastLogin,
    );
  }
}
