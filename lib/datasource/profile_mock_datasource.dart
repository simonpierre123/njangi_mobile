import 'package:flutter/material.dart';
import '../Models/community_model.dart';
import '../Models/profile_model.dart';
import '../utils/app_colors.dart';
import 'community_mock_datasource.dart';

/// Données mock pour la section Profil, en attendant l'API.
///
/// [communities] n'est plus `const` : chaque entrée référence les
/// mêmes instances de [CommunityModel] que [CommunityMockDatasource]
/// (via [CommunityMockDatasource.sample]), pour que taper une
/// communauté ici ouvre le vrai espace communauté déjà construit,
/// au lieu d'un simple libellé.
class ProfileMockDatasource {
  ProfileMockDatasource._();

  static const user = UserProfile(
    name: 'Alex Ngassa',
    phone: '+237 6XX XX XX XX',
    email: 'alex.ngassa@itech.cm',
    gender: 'Homme',
    memberSinceLabel: '12 Octobre 2023',
    isPhoneVerified: true,
    roleSummaryLabel: 'Administrateur de 2 communautés',
  );

  static const activity = ProfileActivity(
    communitiesCount: 3,
    adminCount: 2,
    totalContributions: '450 000 FCFA',
    activeLoans: 0,
  );

  // TODO (Njoya) : "Commerçants Marché" n'existe pas encore dans
  // CommunityMockDatasource — ajoutée ici uniquement le temps du mock.
  // Le rôle "CO-ADMIN" est traité comme 'ADMIN' pour l'ouverture du
  // shell (même privilèges), seul le libellé affiché diffère.
  static const _merchantsCommunity = CommunityModel(
    id: 'merchants',
    name: 'Commerçants Marché',
    icon: Icons.storefront_outlined,
    role: 'ADMIN',
    cycleCurrent: 4,
    cycleTotal: 12,
    memberCount: 20,
    contributionAmount: '30k FCFA',
    contributionFrequency: 'mois',
    progressPercent: 0.33,
    lastUpdateLabel: '5 Nov. 2023',
  );

  static final communities = [
    ProfileCommunityEntry(
      community: CommunityMockDatasource.sample[0], // Famille Bamiléké
      roleLabel: 'ADMIN',
      icon: Icons.groups_outlined,
      iconBg: AppColors.tagMintBg,
      iconColor: AppColors.primaryDark,
    ),
    ProfileCommunityEntry(
      community: CommunityMockDatasource.sample[1], // Promo 2015
      roleLabel: 'Membre',
      icon: Icons.school_outlined,
      iconBg: AppColors.tagMintBg,
      iconColor: AppColors.primaryDark,
    ),
    const ProfileCommunityEntry(
      community: _merchantsCommunity,
      roleLabel: 'CO-ADMIN',
      icon: Icons.storefront_outlined,
      iconBg: AppColors.merchantIconBg,
      iconColor: AppColors.merchantIconColor,
    ),
  ];

  static const security = SecurityStatus(
    levelLabel: 'EXCELLENT',
    checklist: [
      'Numéro vérifié',
      'Code PIN configuré',
      'Authentification biométrique activée',
      'Aucun appareil suspect détecté',
    ],
  );
}