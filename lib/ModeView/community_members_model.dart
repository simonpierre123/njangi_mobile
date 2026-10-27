import 'package:flutter/material.dart';

/// Modèles pour l'onglet "Membres" d'une communauté.
///
/// TODO (Njoya) : à remplacer/aligner sur le modèle réel une fois l'API
/// branchée — alimentés pour l'instant par
/// datasource/community_members_mock_datasource.dart.

enum MemberRowStatus { upToDate, pending, late }

class MemberPersonalDetails {
  const MemberPersonalDetails({
    this.userId,
    this.role,
    this.status,
    this.memberSince,
    this.phone,
    this.email,
    this.gender,
    this.photoUrl,
    this.address,
    this.city,
    this.country,
    this.createdAt,
    this.cniFront,
    this.cniBack,
    this.passport,
    this.drivingLicense,
  });

  final String? userId;
  final String? role;
  final String? status;
  final String? memberSince;
  final String? phone;
  final String? email;
  final String? gender;
  final String? photoUrl;
  final String? address;
  final String? city;
  final String? country;
  final String? createdAt;
  final String? cniFront;
  final String? cniBack;
  final String? passport;
  final String? drivingLicense;

  MemberPersonalDetails copyWith({String? role}) => MemberPersonalDetails(
    userId: userId,
    role: role ?? this.role,
    status: status,
    memberSince: memberSince,
    phone: phone,
    email: email,
    gender: gender,
    photoUrl: photoUrl,
    address: address,
    city: city,
    country: country,
    createdAt: createdAt,
    cniFront: cniFront,
    cniBack: cniBack,
    passport: passport,
    drivingLicense: drivingLicense,
  );
}

/// Une ligne de l'annuaire des membres — vue non-admin.
class MemberDirectoryEntry {
  const MemberDirectoryEntry({
    required this.name,
    required this.memberSinceLabel,
    required this.status,
    this.role,
    this.isHighlighted = false,
    this.details = const MemberPersonalDetails(),
  });

  final String name;
  final String? role; // 'ADMIN' ou null
  final String memberSinceLabel;
  final MemberRowStatus status;
  final bool isHighlighted; // étoile (membre exemplaire)
  final MemberPersonalDetails details;
}

/// Une ligne de l'annuaire des membres — vue admin. Contenu de 2ᵉ ligne
/// différent (statut contextuel plutôt que "présent depuis").
class AdminMemberEntry {
  const AdminMemberEntry({
    required this.name,
    required this.statusLine,
    required this.statusIcon,
    required this.statusColor,
    this.role,
    this.isHighlighted = false,
    this.hasUrgentAction = false,
    this.details = const MemberPersonalDetails(),
  });

  final String name;
  final String? role;
  final String statusLine;
  final IconData statusIcon;
  final Color statusColor;
  final bool isHighlighted;
  final bool hasUrgentAction; // affiche l'icône enveloppe au lieu du menu "..."
  final MemberPersonalDetails details;

  AdminMemberEntry copyWith({String? role, MemberPersonalDetails? details}) =>
      AdminMemberEntry(
        name: name,
        role: role,
        statusLine: statusLine,
        statusIcon: statusIcon,
        statusColor: statusColor,
        isHighlighted: isHighlighted,
        hasUrgentAction: hasUrgentAction,
        details: details ?? this.details,
      );
}

/// Synthèse de la communauté affichée dans la carte verte "La communauté".
class CommunitySummary {
  const CommunitySummary({
    required this.totalMembers,
    required this.adminCount,
    required this.activeCount,
    required this.cycleLabel,
    this.lateCount,
  });

  final int totalMembers;
  final int adminCount;
  final int activeCount;
  final int? lateCount; // affiché seulement côté admin
  final String cycleLabel;
}

/// Score de confiance du groupe — vue non-admin.
class TrustScore {
  const TrustScore({required this.percent, required this.summary});

  final double percent; // 0.0 à 1.0
  final String summary;
}

/// Croissance mensuelle du groupe — vue admin.
class GrowthStats {
  const GrowthStats({required this.newMembersLabel, required this.percent});

  final String newMembersLabel;
  final double percent; // 0.0 à 1.0
}
