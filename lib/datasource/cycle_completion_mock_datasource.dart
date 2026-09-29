import '../Models/cycle_completion_model.dart';

/// Données mock de l'écran "Cycle terminé", en attendant l'API.
class CycleCompletionMockDatasource {
  CycleCompletionMockDatasource._();

  static const closedDateLabel = 'Clôturé le 24 Juil. 2026';

  static const stats = CycleSummaryStats(
    totalMembers: 15,
    potAmount: '2.45M FCFA',
    servedRatio: '12/12',
    activeLoans: 5,
  );

  static const beneficiaryHistory = [
    BeneficiaryHistoryEntry(name: 'Jean Tchoumba', periodLabel: 'Jan 2026 - 200,000 FCFA'),
    BeneficiaryHistoryEntry(name: 'Marie Ndzié', periodLabel: 'Mar 2026 - 200,000 FCFA'),
    BeneficiaryHistoryEntry(name: 'Alex Ngassa', periodLabel: 'Avr 2026 - 200,000 FCFA'),
  ];
}