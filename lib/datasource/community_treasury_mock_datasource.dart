import '../Models/treasury_model.dart';

/// Données mock pour l'espace Trésorerie, en attendant l'API.
class CommunityTreasuryMockDatasource {
  CommunityTreasuryMockDatasource._();

  static const financialPosition = FinancialPosition(
    participationPercent: 100,
    statusLabel: 'À jour',
    totalContributed: '400 000 FCFA',
    activeLoanLabel: 'Aucun',
    nextDueDate: '12 Oct.',
  );

  static const receipt = ContributionReceipt(
    title: "Cotisation d'Octobre",
    dueLabel: 'Échéance : 12 Oct.',
    amount: '50 000 FCFA',
  );

  static const history = [
    ContributionHistoryItem(cycleLabel: 'Cycle 7/12', dateLabel: '12 Septembre 2023', amount: '50 000 FCFA'),
    ContributionHistoryItem(cycleLabel: 'Cycle 6/12', dateLabel: '12 Août 2023', amount: '50 000 FCFA'),
    ContributionHistoryItem(cycleLabel: 'Cycle 5/12', dateLabel: '12 Juillet 2023', amount: '50 000 FCFA'),
  ];

  static const collection = CollectionStatus(
    collectedAmount: '650 000 XAF',
    targetAmount: '750 000 XAF',
    percent: 0.60,
    upToDateCount: 9,
    totalMembers: 15,
    pendingCount: 6,
    nextDueDate: '12 Oct.',
  );

  static const memberContributions = [
    MemberContribution(
      name: 'Marie L.',
      amount: '50 000 FCFA',
      dateLabel: '10 Oct. 2023',
      status: ContributionStatus.upToDate,
    ),
    MemberContribution(
      name: 'Jean D.',
      amount: '50 000 FCFA',
      dateLabel: '11 Oct. 2023',
      status: ContributionStatus.upToDate,
    ),
    MemberContribution(
      name: 'Jean D.',
      amount: '50 000 FCFA',
      dateLabel: '11 Oct. 2023',
      status: ContributionStatus.upToDate,
    ),
    MemberContribution(
      name: 'Alice M.',
      amount: '50 000 FCFA',
      dateLabel: 'En attente',
      status: ContributionStatus.pending,
    ),
  ];

  static const loan = LoanInfo(
    statusLabel: 'En cours',
    borrowedAmount: '250 000 FCFA',
    repaymentPercent: 0.60,
    totalRepaid: '150 000 FCFA',
    remainingBalance: '100 000 FCFA',
  );

  static const loanDue = LoanDueInfo(dueDate: '12 Nov. 2023', amount: '50 000 FCFA');

  static const eligibility = LoanEligibility(
    availableLimit: '500 000 FCFA',
    seniorityLabel: '8 mois',
    hasGoodHistory: true,
  );

  static const repaymentHistory = [
    MemberContribution(name: 'Marie L.', amount: '50 000 FCFA', dateLabel: '12 Oct. 2023', status: ContributionStatus.upToDate),
    MemberContribution(name: 'Marie L.', amount: '50 000 FCFA', dateLabel: '12 Oct. 2023', status: ContributionStatus.upToDate),
    MemberContribution(name: 'Marie L.', amount: '50 000 FCFA', dateLabel: '12 Oct. 2023', status: ContributionStatus.upToDate),
  ];
}