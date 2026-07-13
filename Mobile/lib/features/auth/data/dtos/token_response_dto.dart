/// JWT token pair returned by login and refresh endpoints.
class TokenResponseDto {
  const TokenResponseDto({
    required this.access,
    required this.refresh,
  });

  final String access;
  final String refresh;

  factory TokenResponseDto.fromJson(Map<String, dynamic> json) {
    return TokenResponseDto(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );
  }
}
