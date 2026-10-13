/// Modèles pour "Enregistrer une cotisation" (modal) et "Contribution"
/// (page de détail).
///
/// TODO (Njoya) : à remplacer par les vraies données de l'API — alimentés
/// pour l'instant par datasource/contribution_mock_datasource.dart.

enum ContributionStatusInput { paid, partial, unpaid }

enum PaymentMethod { cash, mobileMoney, transfer }

/// Le membre pour lequel on enregistre une cotisation (carte en haut
/// du modal).
class ContributionMemberSummary {
  const ContributionMemberSummary({
    required this.name,
    required this.expectedAmount,
    required this.statusLabel,
  });

  final String name;
  final String expectedAmount;
  final String statusLabel;
}

/// Détail complet d'une cotisation déjà enregistrée.
class ContributionDetail {
  const ContributionDetail({
    required this.memberName,
    required this.amount,
    required this.periodLabel,
    required this.expectedAmount,
    required this.paidAmount,
    required this.statusLabel,
    required this.dateLabel,
    required this.timeLabel,
    required this.paymentMethodLabel,
    required this.reference,
    required this.recordedByName,
    required this.recordedByRole,
    required this.recordedAtLabel,
    required this.observation,
  });

  final String memberName;
  final String amount;
  final String periodLabel;
  final String expectedAmount;
  final String paidAmount;
  final String statusLabel;
  final String dateLabel;
  final String timeLabel;
  final String paymentMethodLabel;
  final String reference;
  final String recordedByName;
  final String recordedByRole;
  final String recordedAtLabel;
  final String observation;
}