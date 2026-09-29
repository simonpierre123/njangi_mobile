/// Modèles pour l'écran "Cycle terminé" (affiché après confirmation
/// d'un décaissement qui clôture le cycle en cours).
///
/// TODO (Njoya) : à remplacer par les vraies données de l'API — alimentés
/// pour l'instant par datasource/cycle_completion_mock_datasource.dart.

class CycleSummaryStats {
  const CycleSummaryStats({
    required this.totalMembers,
    required this.potAmount,
    required this.servedRatio,
    required this.activeLoans,
  });

  final int totalMembers;
  final String potAmount;
  final String servedRatio; // "12/12"
  final int activeLoans;
}

class BeneficiaryHistoryEntry {
  const BeneficiaryHistoryEntry({
    required this.name,
    required this.periodLabel,
  });

  final String name;
  final String periodLabel; // "Jan 2026 - 200,000 FCFA"
}