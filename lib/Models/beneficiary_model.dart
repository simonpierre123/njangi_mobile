/// Modèles pour l'onglet "Bénéficiaires" de la Trésorerie (tontines à
/// bénéficiaire tournant).
///
/// TODO (Njoya) : à remplacer par les vraies données de l'API — alimentés
/// pour l'instant par datasource/community_beneficiary_mock_datasource.dart.

class CurrentBeneficiary {
  const CurrentBeneficiary({
    required this.name,
    required this.subtitle,
    required this.statusLabel,
    required this.amount,
  });

  final String name;
  final String subtitle; // "Cycle 8 en cours"
  final String statusLabel; // "En attente"
  final String amount;
}

class BeneficiaryStats {
  const BeneficiaryStats({
    required this.totalMembers,
    required this.potAmount,
    required this.servedCount,
    required this.remainingCount,
  });

  final int totalMembers;
  final String potAmount;
  final int servedCount;
  final int remainingCount;
}

/// Une entrée de l'ordre de passage — [order] est la position dans le
/// cycle (8, 9, 10...), [isCurrent] distingue le bénéficiaire du cycle
/// en cours des suivants.
class PassageOrderEntry {
  const PassageOrderEntry({
    required this.order,
    required this.name,
    required this.statusLabel,
    required this.dateBadge,
    required this.isCurrent,
  });

  final int order;
  final String name;
  final String statusLabel; // "Actuel · Cycle 8/12" / "Prochain · Cycle 9/12"
  final String dateBadge; // "AUJOURD'HUI" / "OCT 2023"
  final bool isCurrent;
}

class PayoutHistoryEntry {
  const PayoutHistoryEntry({
    required this.name,
    required this.cycleLabel,
    required this.amount,
  });

  final String name;
  final String cycleLabel;
  final String amount;
}