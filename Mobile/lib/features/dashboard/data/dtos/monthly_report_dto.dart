class MonthlyReportDto {
  const MonthlyReportDto({
    required this.year,
    required this.month,
    required this.contributionsTotal,
    required this.loanOutstanding,
  });

  final int year;
  final int month;
  final String contributionsTotal;
  final String loanOutstanding;

  factory MonthlyReportDto.fromJson(Map<String, dynamic> json) {
    final contributions =
        json['contributions'] as Map<String, dynamic>? ?? {};
    final loans = json['loans'] as Map<String, dynamic>? ?? {};

    return MonthlyReportDto(
      year: json['year'] as int,
      month: json['month'] as int,
      contributionsTotal: contributions['total_amount'] as String? ?? '0.00',
      loanOutstanding: loans['outstanding_balance'] as String? ?? '0.00',
    );
  }
}
