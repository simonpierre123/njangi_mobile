class HomeFinancialSummary {
  const HomeFinancialSummary({
    required this.actionCount,
    required this.debtTotalsByCurrency,
    required this.contributionTotalsByCurrency,
  });

  final int actionCount;
  final Map<String, int> debtTotalsByCurrency;
  final Map<String, int> contributionTotalsByCurrency;

  factory HomeFinancialSummary.fromJson(Map<String, dynamic> json) {
    return HomeFinancialSummary(
      actionCount: (json['nombre_actions'] as num?)?.toInt() ?? 0,
      debtTotalsByCurrency: _parseTotals(json['totaux_dettes_par_devise']),
      contributionTotalsByCurrency: _parseTotals(
        json['totaux_cotisations_par_devise'],
      ),
    );
  }

  String formattedDebtAmount({required String xafLabel}) =>
      _formatTotals(debtTotalsByCurrency, xafLabel);

  String formattedContributionAmount({required String xafLabel}) =>
      _formatTotals(contributionTotalsByCurrency, xafLabel);

  static Map<String, int> _parseTotals(Object? value) {
    if (value is! Map) return const {};

    return value.map(
      (currency, amount) =>
          MapEntry(currency.toString().toUpperCase(), (amount as num).toInt()),
    );
  }

  static String _formatTotals(Map<String, int> totals, String xafLabel) {
    if (totals.isEmpty) return '0 $xafLabel';

    return totals.entries
        .map((entry) {
          final currency = entry.key == 'XAF' ? xafLabel : entry.key;
          return '${_formatInteger(entry.value)} $currency';
        })
        .join(' · ');
  }

  static String _formatInteger(int value) {
    final digits = value.abs().toString();
    final grouped = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        grouped.write(' ');
      }
      grouped.write(digits[index]);
    }
    return value < 0 ? '-$grouped' : grouped.toString();
  }
}
