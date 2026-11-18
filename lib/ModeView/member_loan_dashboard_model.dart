import '../utils/app_constants.dart';

class MemberLoanDashboard {
  const MemberLoanDashboard({
    required this.cycleNumber,
    required this.groupName,
    required this.memberName,
    required this.currency,
    required this.minimumSeniorityMonths,
    required this.seniorityMonths,
    required this.maximumLoanAmount,
    required this.loanModuleActive,
    required this.hasGoodHistory,
    required this.operations,
    this.memberPhotoUrl,
    this.activeLoan,
    this.nextDueDate,
    this.nextDueAmount,
  });

  final int cycleNumber;
  final String groupName;
  final String memberName;
  final String? memberPhotoUrl;
  final String currency;
  final int minimumSeniorityMonths;
  final int seniorityMonths;
  final int maximumLoanAmount;
  final bool loanModuleActive;
  final bool hasGoodHistory;
  final MemberActiveLoan? activeLoan;
  final DateTime? nextDueDate;
  final int? nextDueAmount;
  final List<LoanOperation> operations;

  bool get canRequestLoan =>
      loanModuleActive &&
      activeLoan == null &&
      seniorityMonths >= minimumSeniorityMonths;

  factory MemberLoanDashboard.fromJson(Map<String, dynamic> json) {
    final cycle = _map(json['cycle']);
    final profile = _map(json['profil']);
    final activeLoanData = _map(json['pret_actif']);
    final nextDue = _map(json['prochaine_echeance']);
    final rawPhoto = profile['photo']?.toString().trim();

    return MemberLoanDashboard(
      cycleNumber: _toInt(cycle['numero']),
      groupName: cycle['groupe_nom']?.toString() ?? '',
      memberName: profile['nom']?.toString() ?? '',
      memberPhotoUrl:
          rawPhoto == null || rawPhoto.isEmpty
              ? null
              : rawPhoto.startsWith('http')
              ? rawPhoto
              : '${AppConstants.imageBaseUrl}${rawPhoto.replaceFirst(RegExp(r'^/+'), '')}',
      currency: json['devise']?.toString() ?? 'XAF',
      minimumSeniorityMonths: _toInt(json['anciennete_min_pret_mois']),
      seniorityMonths: _toInt(json['anciennete_mois']),
      maximumLoanAmount: _toInt(json['montant_max_pret']),
      loanModuleActive: _toBool(json['module_pret_actif']) ?? true,
      hasGoodHistory: _toBool(json['historique_exemplaire']) ?? false,
      activeLoan:
          activeLoanData.isEmpty
              ? null
              : MemberActiveLoan.fromJson(activeLoanData),
      nextDueDate: _toDate(nextDue['date']),
      nextDueAmount:
          nextDue.isEmpty ? null : _toInt(nextDue['montant']),
      operations:
          (json['operations'] as List? ?? const [])
              .whereType<Map>()
              .map(
                (operation) =>
                    LoanOperation.fromJson(Map<String, dynamic>.from(operation)),
              )
              .toList(growable: false),
    );
  }
}

class MemberActiveLoan {
  const MemberActiveLoan({
    required this.status,
    required this.borrowedAmount,
    required this.repaidAmount,
    required this.remainingBalance,
  });

  final String status;
  final int borrowedAmount;
  final int repaidAmount;
  final int remainingBalance;

  double get repaymentRatio =>
      borrowedAmount <= 0
          ? 0
          : (repaidAmount / borrowedAmount).clamp(0, 1).toDouble();

  factory MemberActiveLoan.fromJson(Map<String, dynamic> json) =>
      MemberActiveLoan(
        status: json['statut']?.toString() ?? 'EN_COURS',
        borrowedAmount: _toInt(json['montant_emprunte']),
        repaidAmount: _toInt(json['montant_rembourse']),
        remainingBalance: _toInt(json['solde_restant']),
      );
}

class LoanOperation {
  const LoanOperation({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.date,
    this.reason,
    this.rejectionReason,
    this.paymentMode,
    this.paymentReference,
  });

  final String id;
  final String type;
  final int amount;
  final String status;
  final DateTime? date;
  final String? reason;
  final String? rejectionReason;
  final String? paymentMode;
  final String? paymentReference;

  bool get isLoan => type == 'PRET';

  factory LoanOperation.fromJson(Map<String, dynamic> json) => LoanOperation(
    id: json['id']?.toString() ?? '',
    type: json['type']?.toString() ?? '',
    amount: _toInt(json['montant']),
    status: json['statut']?.toString() ?? 'EN_ATTENTE',
    date: _toDate(json['date_operation']),
    reason: _optionalString(json['motif']),
    rejectionReason: _optionalString(json['motif_rejet']),
    paymentMode: _optionalString(json['mode_paiement']),
    paymentReference: _optionalString(json['reference_paiement']),
  );
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

int _toInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

bool? _toBool(dynamic value) => switch (value) {
  bool value => value,
  num value => value != 0,
  String value => switch (value.toLowerCase()) {
    '1' || 'true' => true,
    '0' || 'false' => false,
    _ => null,
  },
  _ => null,
};

DateTime? _toDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String? _optionalString(dynamic value) {
  final string = value?.toString().trim();
  return string == null || string.isEmpty ? null : string;
}
