class MemberSavingsDashboard {
  const MemberSavingsDashboard({
    required this.memberBalance,
    required this.totalBalance,
    required this.validatedMemberCount,
    required this.totalValidatedCount,
    required this.pendingMemberCount,
    required this.currency,
    required this.operations,
  });

  final int memberBalance;
  final int totalBalance;
  final int validatedMemberCount;
  final int totalValidatedCount;
  final int pendingMemberCount;
  final String currency;
  final List<MemberSavingsOperation> operations;

  double get balanceShare =>
      totalBalance <= 0
          ? 0
          : (memberBalance / totalBalance).clamp(0, 1).toDouble();

  factory MemberSavingsDashboard.fromJson(Map<String, dynamic> json) {
    final rawOperations = json['operations'];
    return MemberSavingsDashboard(
      memberBalance: _toInt(json['solde_membre']),
      totalBalance: _toInt(json['solde_total']),
      validatedMemberCount: _toInt(json['transactions_validees_membre']),
      totalValidatedCount: _toInt(json['transactions_validees_total']),
      pendingMemberCount: _toInt(json['transactions_en_attente_membre']),
      currency: json['devise']?.toString() ?? 'XAF',
      operations:
          rawOperations is List
              ? rawOperations
                  .whereType<Map>()
                  .map(
                    (item) => MemberSavingsOperation.fromJson(
                      Map<String, dynamic>.from(item),
                    ),
                  )
                  .toList(growable: false)
              : const [],
    );
  }
}

class MemberSavingsOperation {
  const MemberSavingsOperation({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.date,
    this.period,
    this.rejectionReason,
  });

  final String id;
  final String type;
  final int amount;
  final String status;
  final DateTime? date;
  final String? period;
  final String? rejectionReason;

  factory MemberSavingsOperation.fromJson(Map<String, dynamic> json) {
    return MemberSavingsOperation(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'EPARGNE',
      amount: _toInt(json['montant']),
      status: json['statut']?.toString() ?? 'EN_ATTENTE',
      date:
          DateTime.tryParse(
            json['date_operation']?.toString() ??
                json['created_at']?.toString() ??
                '',
          )?.toLocal(),
      period: json['periode']?.toString(),
      rejectionReason: json['motif_rejet']?.toString(),
    );
  }
}

int _toInt(Object? value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
