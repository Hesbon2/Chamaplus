/// Login request payload matching the Django API.
class LoginRequestDto {
  const LoginRequestDto({
    required this.phoneNumber,
    required this.password,
  });

  final String phoneNumber;
  final String password;

  Map<String, dynamic> toJson() => {
        'phone_number': phoneNumber,
        'password': password,
      };
}
