import 'package:flutter/material.dart';

/// Modèles de données pour le tableau de bord admin d'une communauté.
///
/// TODO (Njoya) : à remplacer/aligner sur le modèle réel une fois l'API
/// branchée — alimentés pour l'instant par
/// datasource/community_admin_mock_datasource.dart.

class GroupHealthStats {
  const GroupHealthStats({
    required this.healthPercent,
    required this.healthLabel,
    required this.cashBalance,
    required this.membersUpToDate,
    required this.membersTotal,
    required this.pendingCount,
    required this.activeLoans,
    required this.lastUpdateLabel,
  });

  final int healthPercent;
  final String healthLabel;
  final String cashBalance;
  final int membersUpToDate;
  final int membersTotal;
  final int pendingCount;
  final int activeLoans;
  final String lastUpdateLabel;
}

class PriorityItem {
  const PriorityItem({required this.icon, required this.label, this.isAlert = false});

  final IconData icon;
  final String label;
  final bool isAlert;
}

class CycleInfo {
  const CycleInfo({
    required this.currentCycle,
    required this.totalCycle,
    required this.progressPercent,
    required this.nextBeneficiary,
    required this.remainingCycles,
  });

  final int currentCycle;
  final int totalCycle;
  final double progressPercent; // 0.0 à 1.0
  final String nextBeneficiary;
  final int remainingCycles;
}

class MemberStatusStats {
  const MemberStatusStats({
    required this.total,
    required this.upToDate,
    required this.pending,
    required this.lateCount,
  });

  final int total;
  final int upToDate;
  final int pending;
  final int lateCount;
}

class LoanStats {
  const LoanStats({
    required this.activeLoans,
    required this.pendingRequests,
    required this.overdue,
    required this.borrowingCapacity,
  });

  final int activeLoans;
  final int pendingRequests;
  final int overdue;
  final String borrowingCapacity;
}

class ActivityItem {
  const ActivityItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
}