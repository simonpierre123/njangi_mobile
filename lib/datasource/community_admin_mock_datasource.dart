import 'package:flutter/material.dart';
import '../ModeView/community_admin_dashboard_model.dart';
import '../utils/app_colors.dart';

/// Données mock pour le tableau de bord admin, en attendant l'API.
/// Isolé ici pour que le remplacement par les vraies données ne touche
/// pas aux écrans qui les consomment.
class CommunityAdminMockDatasource {
  CommunityAdminMockDatasource._();

  static const cycle = CycleInfo(
    currentCycle: 8,
    totalCycle: 12,
    progressPercent: 0.65,
    nextBeneficiary: 'Jean D.',
    remainingBeneficiaries: 4,
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
    borrowingCapacity: 1200000,
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
