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
    this.isCashBalanceLoading = false,
    this.cashBalanceError = false,
    this.isHealthLoading = false,
  });

  final int? healthPercent;
  final String healthLabel;
  final String cashBalance;
  final int membersUpToDate;
  final int membersTotal;
  final int pendingCount;
  final int activeLoans;
  final String lastUpdateLabel;
  final bool isCashBalanceLoading;
  final bool cashBalanceError;
  final bool isHealthLoading;
}

class PriorityItem {
  const PriorityItem({
    required this.icon,
    required this.label,
    this.isAlert = false,
    this.actionKey,
  });

  final IconData icon;
  final String label;
  final bool isAlert;
  final String? actionKey;
}

class CycleInfo {
  const CycleInfo({
    required this.currentCycle,
    required this.totalCycle,
    required this.progressPercent,
    required this.nextBeneficiary,
    required this.remainingBeneficiaries,
  });

  final int currentCycle;
  final int totalCycle;
  final double? progressPercent; // 0.0 à 1.0
  final String nextBeneficiary;
  final int? remainingBeneficiaries;
}

class MemberStatusStats {
  const MemberStatusStats({
    required this.total,
    required this.upToDate,
    required this.pending,
    required this.lateCount,
    this.isLoading = false,
    this.hasError = false,
  });

  final int total;
  final int upToDate;
  final int pending;
  final int lateCount;
  final bool isLoading;
  final bool hasError;
}

class LoanStats {
  const LoanStats({
    required this.activeLoans,
    required this.pendingRequests,
    required this.overdue,
    required this.borrowingCapacity,
    this.currency = 'XAF',
    this.isLoading = false,
    this.hasError = false,
  });

  final int activeLoans;
  final int pendingRequests;
  final int overdue;
  final int borrowingCapacity;
  final String currency;
  final bool isLoading;
  final bool hasError;

  factory LoanStats.fromJson(Map<String, dynamic> json) {
    int readCount(String key) {
      final value = json[key];
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      throw FormatException('Invalid loan dashboard field: $key');
    }

    return LoanStats(
      activeLoans: readCount('prets_actifs'),
      pendingRequests: readCount('demandes_en_attente'),
      overdue: readCount('prets_en_retard'),
      borrowingCapacity: readCount('capacite_emprunt'),
      currency: json['devise']?.toString() ?? 'XAF',
    );
  }

  static const loading = LoanStats(
    activeLoans: 0,
    pendingRequests: 0,
    overdue: 0,
    borrowingCapacity: 0,
    isLoading: true,
  );

  static const error = LoanStats(
    activeLoans: 0,
    pendingRequests: 0,
    overdue: 0,
    borrowingCapacity: 0,
    hasError: true,
  );
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
