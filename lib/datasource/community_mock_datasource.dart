import 'package:flutter/material.dart';
import '../Models/community_model.dart';

/// Source de données mock pour le tableau de bord, en attendant
/// l'intégration API réelle. À remplacer par un vrai datasource
/// (requêtes HTTP / repository) une fois le backend branché — c'est
/// volontairement isolé ici pour que ce remplacement ne touche pas
/// aux écrans qui consomment ces données.
class CommunityMockDatasource {
  CommunityMockDatasource._();

  static const empty = <CommunityModel>[];

  static const sample = <CommunityModel>[
    CommunityModel(
      id: '1',
      name: 'Famille Bamiléké',
      icon: Icons.people,
      role: 'ADMIN',
      cycleCurrent: 8,
      cycleTotal: 12,
      memberCount: 15,
      contributionAmount: '50k FCFA',
      contributionFrequency: 'mois',
      progressPercent: 0.6,
      lastUpdateLabel: '12 Oct. 2023',
      badgeLabel: 'Réunion demain',
      badgeType: CommunityBadgeType.info,
      statusLabel: 'À jour',
    ),
    CommunityModel(
      id: '2',
      name: 'Promo 2015',
      icon: Icons.school,
      cycleCurrent: 3,
      cycleTotal: 10,
      memberCount: 25,
      contributionAmount: '25k FCFA',
      contributionFrequency: 'mois',
      progressPercent: 0.3,
      lastUpdateLabel: '25 Oct. 2023',
      badgeLabel: 'En retard',
      badgeType: CommunityBadgeType.warning,
      actionLabel: 'Payer maintenant',
    ),
    CommunityModel(
      id: '3',
      name: 'Tontine Quartier',
      icon: Icons.savings_outlined,
      cycleCurrent: 5,
      cycleTotal: 12,
      memberCount: 10,
      contributionAmount: '10k FCFA',
      contributionFrequency: 'mois',
      progressPercent: 0.42,
      lastUpdateLabel: '18 Oct. 2023',
      statusLabel: 'À jour',
    ),
  ];
}