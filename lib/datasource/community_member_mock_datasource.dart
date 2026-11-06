import 'package:flutter/material.dart';
import '../ModeView/community_admin_dashboard_model.dart';
import '../ModeView/community_member_dashboard_model.dart';
import '../utils/app_colors.dart';

/// Données mock pour le tableau de bord membre (non-admin), en attendant
/// l'API. Isolé ici pour que le remplacement par les vraies données ne
/// touche pas aux écrans qui les consomment.
class CommunityMemberMockDatasource {
  CommunityMemberMockDatasource._();

  static const cycle = MemberCycleInfo(
    progressPercent: 0.6,
    progressLabel: 'Complétée',
    nextBeneficiary: 'Jean D.',
    remainingBeneficiaries: 4,
  );

  static const memberStatus = MemberStatusStats(
    total: 15,
    upToDate: 12,
    pending: 3,
    lateCount: 1,
  );

  static const activity = [
    ActivityItem(
      icon: Icons.person_outline,
      iconBg: AppColors.tagMintBg,
      iconColor: AppColors.primaryContainer,
      title: 'Marie a cotisé 50 000 FCFA',
      subtitle: 'Il y a 2h',
    ),
    ActivityItem(
      icon: Icons.event_outlined,
      iconBg: AppColors.warningBg,
      iconColor: AppColors.amber,
      title: 'Réunion planifiée',
      subtitle: 'Il y a 5h',
    ),
    ActivityItem(
      icon: Icons.check_circle_outline,
      iconBg: AppColors.purpleBg,
      iconColor: AppColors.purple,
      title: 'Prêt approuvé pour Alex',
      subtitle: 'Hier',
    ),
  ];
}
