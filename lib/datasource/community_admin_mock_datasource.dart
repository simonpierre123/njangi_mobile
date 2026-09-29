import 'package:flutter/material.dart';
import '../Models/community_admin_dashboard_model.dart';
import '../utils/app_colors.dart';

/// Données mock pour le tableau de bord admin, en attendant l'API.
/// Isolé ici pour que le remplacement par les vraies données ne touche
/// pas aux écrans qui les consomment.
class CommunityAdminMockDatasource {
  CommunityAdminMockDatasource._();

  static const health = GroupHealthStats(
    healthPercent: 94,
    healthLabel: 'Stable',
    cashBalance: '2 450 000 FCFA',
    membersUpToDate: 12,
    membersTotal: 15,
    pendingCount: 3,
    activeLoans: 2,
    lastUpdateLabel: 'Mis à jour il y a 5 min',
  );

  static const priorities = [
    PriorityItem(icon: Icons.payment, label: '3 cotisations à enregistrer'),
    PriorityItem(icon: Icons.description_outlined, label: '2 demandes de prêt'),
    PriorityItem(icon: Icons.warning_amber_rounded, label: '1 membre en retard', isAlert: true),
  ];

  static const cycle = CycleInfo(
    currentCycle: 8,
    totalCycle: 12,
    progressPercent: 0.65,
    nextBeneficiary: 'Jean D.',
    remainingCycles: 4,
  );

  static const memberStatus = MemberStatusStats(
    total: 15,
    upToDate: 11,
    pending: 3,
    lateCount: 1,
  );

  static const loans = LoanStats(
    activeLoans: 2,
    pendingRequests: 2,
    overdue: 0,
    borrowingCapacity: '1 200 000 FCFA',
  );

  static const activity = [
    ActivityItem(
      icon: Icons.payments_outlined,
      iconBg: AppColors.tagMintBg,
      iconColor: AppColors.primaryContainer,
      title: 'Cotisation enregistrée (Marie)',
      subtitle: 'Il y a 2h • Transaction #TR9482',
    ),
    ActivityItem(
      icon: Icons.check_circle_outline,
      iconBg: AppColors.purpleBg,
      iconColor: AppColors.purple,
      title: 'Prêt approuvé (Alex)',
      subtitle: 'Il y a 5h • Montant : 250 000 FCFA',
    ),
    ActivityItem(
      icon: Icons.person_add_alt_1_outlined,
      iconBg: AppColors.warningBg,
      iconColor: AppColors.amber,
      title: 'Nouveau membre (Thomas L.)',
      subtitle: 'Hier • Profil en attente de vérification',
    ),
  ];
}