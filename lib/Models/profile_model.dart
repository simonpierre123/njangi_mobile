import 'package:flutter/material.dart';
import 'community_model.dart';

/// Modèles pour la section "Profil" (compte utilisateur, sécurité).
///
/// TODO (Njoya) : à remplacer par les données réelles une fois l'API
/// branchée — alimentés pour l'instant par
/// datasource/profile_mock_datasource.dart.

class UserProfile {
  const UserProfile({
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    required this.memberSinceLabel,
    required this.isPhoneVerified,
    required this.roleSummaryLabel,
  });

  final String name;
  final String phone;
  final String email;
  final String gender;
  final String memberSinceLabel;
  final bool isPhoneVerified;
  final String roleSummaryLabel; // ex: "Administrateur de 2 communautés"
}

class ProfileActivity {
  const ProfileActivity({
    required this.communitiesCount,
    required this.adminCount,
    required this.totalContributions,
    required this.activeLoans,
  });

  final int communitiesCount;
  final int adminCount;
  final String totalContributions;
  final int activeLoans;
}

/// Une communauté listée dans le hub Profil. Porte le vrai
/// [CommunityModel] (pas juste un nom) pour pouvoir router directement
/// vers l'espace communauté déjà construit au tap.
class ProfileCommunityEntry {
  const ProfileCommunityEntry({
    required this.community,
    required this.roleLabel,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final CommunityModel community;
  final String roleLabel;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  String get name => community.name;
}

class SecurityStatus {
  const SecurityStatus({required this.levelLabel, required this.checklist});

  final String levelLabel; // ex: "EXCELLENT"
  final List<String> checklist;
}