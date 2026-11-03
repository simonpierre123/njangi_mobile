class CycleCashBalance {
  const CycleCashBalance({required this.amount, required this.currency});

  final int amount;
  final String currency;

  factory CycleCashBalance.fromJson(Map<String, dynamic> json) {
    final amount = json['solde_caisse'];
    final currency = json['devise']?.toString();
    if (currency == null || currency.isEmpty) {
      throw const FormatException('Missing cash balance currency');
    }

    final parsedAmount =
        amount is num ? amount.toInt() : int.tryParse(amount?.toString() ?? '');
    if (parsedAmount == null) {
      throw const FormatException('Invalid cash balance amount');
    }

    return CycleCashBalance(amount: parsedAmount, currency: currency);
  }
}
