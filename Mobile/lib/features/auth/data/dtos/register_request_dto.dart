/// Registration payload for `POST /auth/register/`.
class RegisterRequestDto {
  const RegisterRequestDto({
    required this.phoneNumber,
    required this.password,
    required this.passwordConfirm,
    this.firstName,
    this.lastName,
    this.email,
  });

  final String phoneNumber;
  final String password;
  final String passwordConfirm;
  final String? firstName;
  final String? lastName;
  final String? email;

  Map<String, dynamic> toJson() => {
        'phone_number': phoneNumber,
        'password': password,
        'password_confirm': passwordConfirm,
        if (firstName != null && firstName!.trim().isNotEmpty)
          'first_name': firstName!.trim(),
        if (lastName != null && lastName!.trim().isNotEmpty)
          'last_name': lastName!.trim(),
        if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
      };
}
