/// Modèles pour l'espace "Trésorerie" d'une communauté.
///
/// TODO (Njoya) : à remplacer/aligner sur le modèle réel une fois l'API
/// branchée — alimentés pour l'instant par
/// datasource/community_treasury_mock_datasource.dart.

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

/// Reçu de cotisation en attente/à venir.
class ContributionReceipt {
  const ContributionReceipt({
    required this.title,
    required this.dueLabel,
    required this.amount,
  });

  final String title;
  final String dueLabel;
  final String amount;
}

/// Une ligne de l'historique de cotisations personnelles.
class ContributionHistoryItem {
  const ContributionHistoryItem({
    required this.cycleLabel,
    required this.dateLabel,
    required this.amount,
  });

  final String cycleLabel;
  final String dateLabel;
  final String amount;
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