import 'package:flutter/material.dart';
import 'community_model.dart';
import '../Models/user_model.dart';
import '../utils/app_constants.dart';

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
    this.photoUrl,
    this.cniRecto,
    this.cniVerso,
    this.passport,
  });

  final String name;
  final String phone;
  final String email;
  final String gender;
  final String memberSinceLabel;
  final bool isPhoneVerified;
  final String roleSummaryLabel; // ex: "Administrateur de 2 communautés"
  final String? photoUrl;
  final String? cniRecto;
  final String? cniVerso;
  final String? passport;

  bool get isKycComplete =>
      (passport?.trim().isNotEmpty ?? false) ||
      ((cniRecto?.trim().isNotEmpty ?? false) &&
          (cniVerso?.trim().isNotEmpty ?? false));

  factory UserProfile.fromUserModel(UserModel user) {
    final name = [user.prenom, user.nom]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join(' ');
    final storedPhoto = user.photo?.trim();
    final photoUrl =
        storedPhoto == null || storedPhoto.isEmpty
            ? null
            : storedPhoto.startsWith('http')
            ? storedPhoto
            : '${AppConstants.imageBaseUrl}${storedPhoto.replaceFirst(RegExp(r'^/+'), '')}';

    return UserProfile(
      name: name.isEmpty ? user.telephone : name,
      phone: user.telephone,
      email: user.email ?? '',
      gender: user.sexe ?? '',
      memberSinceLabel: user.createdAt ?? '',
      isPhoneVerified: user.statut == 1,
      roleSummaryLabel: '',
      photoUrl: photoUrl,
      cniRecto: user.cniRecto,
      cniVerso: user.cniVerso,
      passport: user.passport,
    );
  }
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
