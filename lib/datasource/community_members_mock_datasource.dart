import 'package:flutter/material.dart';
import '../Models/community_members_model.dart';
import '../utils/app_colors.dart';

/// Données mock pour l'onglet Membres, en attendant l'API.
class CommunityMembersMockDatasource {
  CommunityMembersMockDatasource._();

  static const summaryMember = CommunitySummary(
    totalMembers: 15,
    adminCount: 1,
    activeCount: 14,
    cycleLabel: '8/12',
  );

  static const summaryAdmin = CommunitySummary(
    totalMembers: 15,
    adminCount: 2,
    activeCount: 14,
    lateCount: 1,
    cycleLabel: '8/12',
  );

  static const directory = [
    MemberDirectoryEntry(
      name: 'Marie L.',
      role: 'ADMIN',
      memberSinceLabel: 'Présente depuis Janvier 2023',
      status: MemberRowStatus.upToDate,
    ),
    MemberDirectoryEntry(
      name: 'Jean D.',
      memberSinceLabel: 'Présent depuis Mars 2023',
      status: MemberRowStatus.upToDate,
    ),
    MemberDirectoryEntry(
      name: 'Thomas B.',
      memberSinceLabel: 'Présent depuis Janvier 2023',
      status: MemberRowStatus.upToDate,
      isHighlighted: true,
    ),
    MemberDirectoryEntry(
      name: 'Alice M.',
      memberSinceLabel: 'Présente depuis Juin 2023',
      status: MemberRowStatus.late,
    ),
  ];

  static const adminDirectory = [
    AdminMemberEntry(
      name: 'Marie L.',
      role: 'ADMIN',
      statusLine: 'Janvier 2023 • À jour',
      statusIcon: Icons.circle,
      statusColor: AppColors.primary,
    ),
    AdminMemberEntry(
      name: 'Jean D.',
      statusLine: 'Prochain bénéficiaire',
      statusIcon: Icons.circle,
      statusColor: AppColors.primary,
      isHighlighted: true,
    ),
    AdminMemberEntry(
      name: 'Thomas B.',
      statusLine: 'Prêt en attente',
      statusIcon: Icons.schedule,
      statusColor: AppColors.warningText,
    ),
    AdminMemberEntry(
      name: 'Alice M.',
      statusLine: 'En retard (Mars)',
      statusIcon: Icons.warning_amber_rounded,
      statusColor: AppColors.alertRed,
      hasUrgentAction: true,
    ),
  ];

  static const trustScore = TrustScore(
    percent: 0.98,
    summary: 'Excellent, 14 membres sur 15 sont à jour.',
  );

  static const growth = GrowthStats(newMembersLabel: '+2 Nouveaux', percent: 0.94);
}