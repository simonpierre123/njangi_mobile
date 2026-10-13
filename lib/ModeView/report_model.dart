import 'package:flutter/material.dart';

/// Modèles pour "Résumé financier" et "Rapport détaillé".
///
/// TODO (Njoya) : à remplacer par les vraies données de l'API — alimentés
/// pour l'instant par datasource/report_mock_datasource.dart.

class FinancialSummary {
  const FinancialSummary({
    required this.currentBalance,
    required this.totalContributions,
    required this.totalDisbursements,
    required this.activeLoans,
  });

  final String currentBalance;
  final String totalContributions;
  final String totalDisbursements;
  final String activeLoans;
}

/// Point de la courbe "Évolution des contributions" — [value] normalisé
/// entre 0.0 et 1.0 pour le tracé.
class ChartPoint {
  const ChartPoint({required this.label, required this.value});

  final String label;
  final double value;
}

class ParticipationBreakdown {
  const ParticipationBreakdown({
    required this.percent,
    required this.totalMembers,
    required this.upToDateCount,
    required this.lateCount,
    required this.partialCount,
  });

  final double percent;
  final int totalMembers;
  final int upToDateCount;
  final int lateCount;
  final int partialCount;
}

class LoanReportDetails {
  const LoanReportDetails({
    required this.activeLoans,
    required this.repaymentRateLabel,
    required this.totalLoanAmount,
  });

  final int activeLoans;
  final String repaymentRateLabel;
  final String totalLoanAmount;
}

class RecentReportActivity {
  const RecentReportActivity({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.titlePrefix,
    required this.personName,
    required this.amountLabel,
    required this.amountColor,
    required this.timeLabel,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String titlePrefix; // "Cotisation de" / "Décaissement de" / "Remboursement de"
  final String personName;
  final String amountLabel; // déjà signé, ex: "+ 50 000 FCFA"
  final Color amountColor;
  final String timeLabel;
}

// ---------------- Rapport détaillé (Contributions) ----------------

enum ReportPeriodFilter { all, today, thisWeek, thisMonth }

class DetailedReportSummary {
  const DetailedReportSummary({
    required this.totalCollected,
    required this.changeLabel,
    required this.updatedAtLabel,
    required this.transactionsCount,
  });

  final String totalCollected;
  final String changeLabel; // "+12% vs hier"
  final String updatedAtLabel; // "Actualisé à 14:30"
  final int transactionsCount;
}

class ReportTransaction {
  const ReportTransaction({
    required this.memberName,
    required this.amountLabel,
    required this.statusLabel,
    required this.isPaid,
    required this.dateLabel,
  });

  final String memberName;
  final String amountLabel;
  final String statusLabel;
  final bool isPaid;
  final String dateLabel;
}