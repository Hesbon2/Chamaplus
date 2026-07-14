class ChamaDto {
  const ChamaDto({
    required this.id,
    required this.name,
    required this.currency,
  });

  final String id;
  final String name;
  final String currency;

  factory ChamaDto.fromJson(Map<String, dynamic> json) {
    return ChamaDto(
      id: json['id'] as String,
      name: json['name'] as String,
      currency: json['currency'] as String? ?? 'KES',
    );
  }
}
