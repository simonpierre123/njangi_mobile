import 'package:flutter/material.dart';
import '../Models/community_admin_dashboard_model.dart';
import '../Models/community_member_dashboard_model.dart';
import '../utils/app_colors.dart';
import 'community_admin_mock_datasource.dart';

/// Données mock pour le tableau de bord membre (non-admin), en attendant
/// l'API. Isolé ici pour que le remplacement par les vraies données ne
/// touche pas aux écrans qui les consomment.
class CommunityMemberMockDatasource {
  CommunityMemberMockDatasource._();

  // Santé du groupe identique à la vue admin — réutilisation directe,
  // pas de duplication de données.
  static const health = CommunityAdminMockDatasource.health;

  static const requiredActions = [
    RequiredActionItem(
      icon: Icons.payments_outlined,
      title: 'Cotisation due',
      subtitle: '50 000 FCFA • Aujourd\'hui',
      actionLabel: 'Payer',
    ),
    RequiredActionItem(
      icon: Icons.event_outlined,
      title: 'Réunion de groupe',
      subtitle: 'Demain à 18h00',
    ),
  ];

  static const cycle = MemberCycleInfo(
    progressPercent: 0.6,
    progressLabel: 'Complétée',
    nextBeneficiary: 'Jean D.',
    remainingCycles: 4,
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