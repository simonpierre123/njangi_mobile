import 'package:flutter/material.dart';
import '../Models/report_model.dart';
import '../utils/app_colors.dart';

/// Données mock des rapports, en attendant l'API.
class ReportMockDatasource {
  ReportMockDatasource._();

  // ---------------- Résumé financier ----------------

  static const summary = FinancialSummary(
    currentBalance: '2 450 000 FCFA',
    totalContributions: '3 850 000 FCFA',
    totalDisbursements: '1 200 000 FCFA',
    activeLoans: '250 000 FCFA',
  );

  static const contributionEvolution = [
    ChartPoint(label: 'Jan', value: 0.35),
    ChartPoint(label: 'Fév', value: 0.42),
    ChartPoint(label: 'Mar', value: 0.48),
    ChartPoint(label: 'Avr', value: 0.55),
    ChartPoint(label: 'Mai', value: 0.68),
    ChartPoint(label: 'Jun', value: 0.80),
    ChartPoint(label: 'Jul', value: 1.0),
  ];

  static const participation = ParticipationBreakdown(
    percent: 0.80,
    totalMembers: 15,
    upToDateCount: 12,
    lateCount: 2,
    partialCount: 1,
  );

  static const loanDetails = LoanReportDetails(
    activeLoans: 2,
    repaymentRateLabel: '95%',
    totalLoanAmount: '250 000 FCFA',
  );

  static const recentActivity = [
    RecentReportActivity(
      icon: Icons.payments_outlined,
      iconBg: AppColors.tagMintBg,
      iconColor: AppColors.primaryDark,
      titlePrefix: 'Cotisation de',
      personName: 'Marie',
      amountLabel: '+ 50 000 FCFA',
      isPositive: true,
      timeLabel: "Aujourd'hui, 10:45",
    ),
    RecentReportActivity(
      icon: Icons.arrow_upward,
      iconBg: AppColors.tagRedBg,
      iconColor: AppColors.alertRed,
      titlePrefix: 'Décaissement de',
      personName: 'Jean',
      amountLabel: '- 150 000 FCFA',
      isPositive: false,
      timeLabel: 'Hier, 16:20',
    ),
    RecentReportActivity(
      icon: Icons.autorenew,
      iconBg: AppColors.purpleBg,
      iconColor: AppColors.purple,
      titlePrefix: 'Remboursement de',
      personName: 'Thomas',
      amountLabel: '+ 25 000 FCFA',
      isPositive: true,
      timeLabel: 'Il y a 2 jours',
    ),
  ];

  // ---------------- Rapport détaillé ----------------

  static const detailedSummary = DetailedReportSummary(
    totalCollected: '3 850 000 FCFA',
    changeLabel: '+12% vs hier',
    updatedAtLabel: 'Actualisé à 14:30',
    transactionsCount: 15,
  );

  static const versementsEvolution = [
    ChartPoint(label: '08:00', value: 0.35),
    ChartPoint(label: '10:00', value: 0.5),
    ChartPoint(label: '12:00', value: 1.0),
    ChartPoint(label: '14:00', value: 0.55),
    ChartPoint(label: '16:00', value: 0.65),
    ChartPoint(label: '18:00', value: 0.45),
    ChartPoint(label: '20:00', value: 0.4),
  ];

  static const transactions = [
    ReportTransaction(
      memberName: 'Mario Tagne',
      amountLabel: '50 000 FCFA',
      statusLabel: 'Payée',
      isPaid: true,
      dateLabel: '12 Jui., 14:30',
    ),
    ReportTransaction(
      memberName: 'Jean-Paul Kamga',
      amountLabel: '100 000 FCFA',
      statusLabel: 'Payée',
      isPaid: true,
      dateLabel: '12 Jui., 12:15',
    ),
    ReportTransaction(
      memberName: 'Alice Fotso',
      amountLabel: '50 000 FCFA',
      statusLabel: 'En attente',
      isPaid: false,
      dateLabel: '12 Jui., 10:45',
    ),
    ReportTransaction(
      memberName: 'David Simo',
      amountLabel: '75 000 FCFA',
      statusLabel: 'Payée',
      isPaid: true,
      dateLabel: '12 Jui., 09:20',
    ),
  ];
}