import '../Models/Cycle.dart';

// Les modèles du reçu et de l'historique correspondent aux données de l'API;
// les autres sections de la trésorerie restent partiellement alimentées par mocks.

enum ContributionStatus { upToDate, pending, late }

/// Position financière personnelle du membre (onglet "Ma Trésorerie").
class FinancialPosition {
  const FinancialPosition({
    required this.participationPercent,
    required this.statusLabel,
    required this.totalContributed,
    required this.activeLoanLabel,
    required this.nextDueDate,
  });

  final int participationPercent;
  final String statusLabel;
  final String totalContributed;
  final String activeLoanLabel;
  final String nextDueDate;
}

/// Détails d'une cotisation Tontine validée.
class ContributionReceipt {
  const ContributionReceipt({
    required this.title,
    required this.dueLabel,
    required this.amount,
    this.operationId,
    this.cycleLabel,
    this.groupName,
    this.period,
    this.operationDate,
    this.validatedAt,
    this.paymentMode,
    this.operator,
    this.paymentReference,
    this.validatorName,
    this.isSimulation = false,
  });

  final String title;
  final String dueLabel;
  final String amount;
  final String? operationId;
  final String? cycleLabel;
  final String? groupName;
  final String? period;
  final String? operationDate;
  final String? validatedAt;
  final String? paymentMode;
  final String? operator;
  final String? paymentReference;
  final String? validatorName;
  final bool isSimulation;
}

/// A cycle displayed in the member's cycle history.
class CycleHistoryItem {
  const CycleHistoryItem({
    required this.id,
    required this.number,
    required this.amount,
    required this.currency,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
  });

  final String id;
  final int number;
  final int amount;
  final String currency;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
}

List<CycleHistoryItem> cycleHistoryFromCycles(Iterable<Cycle> cycles) {
  final eligibleCycles =
      cycles
          .where(
            (cycle) =>
                cycle.status == 'EN_COURS' || cycle.status == 'TERMINEE',
          )
          .where((cycle) => cycle.id != null)
          .toList()
        ..sort(
          (first, second) =>
              (second.number ?? 0).compareTo(first.number ?? 0),
        );

  return eligibleCycles
      .map(
        (cycle) => CycleHistoryItem(
          id: cycle.id!,
          number: cycle.number ?? 0,
          amount: cycle.contributionAmount ?? 0,
          currency: cycle.currency ?? 'XAF',
          startDate: cycle.startDate,
          endDate: cycle.endDate,
          isCurrent: cycle.status == 'EN_COURS',
        ),
      )
      .toList(growable: false);
}

List<CycleHistoryItem> visibleCycleHistory(
  List<CycleHistoryItem> items, {
  required bool expanded,
}) {
  if (expanded || items.length <= 3) return items;
  return items.take(3).toList(growable: false);
}

/// État global de la collecte (onglet "Contributions").
class CollectionStatus {
  const CollectionStatus({
    required this.collectedAmount,
    required this.targetAmount,
    required this.percent,
    required this.upToDateCount,
    required this.totalMembers,
    required this.pendingCount,
    required this.nextDueDate,
  });

  final String collectedAmount;
  final String targetAmount;
  final double percent; // 0.0 à 1.0
  final int upToDateCount;
  final int totalMembers;
  final int pendingCount;
  final String nextDueDate;
}

/// Résumé du prêt en cours du membre (onglet "Prêts").
class LoanInfo {
  const LoanInfo({
    required this.statusLabel,
    required this.borrowedAmount,
    required this.repaymentPercent,
    required this.totalRepaid,
    required this.remainingBalance,
  });

  final String statusLabel;
  final String borrowedAmount;
  final double repaymentPercent; // 0.0 à 1.0
  final String totalRepaid;
  final String remainingBalance;
}

/// Prochaine échéance de remboursement.
class LoanDueInfo {
  const LoanDueInfo({required this.dueDate, required this.amount});

  final String dueDate;
  final String amount;
}

/// Éligibilité du membre à une nouvelle demande de prêt, affichée quand
/// il n'a aucun prêt en cours.
class LoanEligibility {
  const LoanEligibility({
    required this.availableLimit,
    required this.seniorityLabel,
    required this.hasGoodHistory,
  });

  final String availableLimit;
  final String seniorityLabel;
  final bool hasGoodHistory;
}

/// Une ligne de contribution d'un membre du groupe.
class MemberContribution {
  const MemberContribution({
    required this.name,
    required this.amount,
    required this.dateLabel,
    required this.status,
  });

  final String name;
  final String amount;
  final String dateLabel;
  final ContributionStatus status;
}