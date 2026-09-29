import 'package:flutter/material.dart';

/// Modèles pour l'onglet "Membres" d'une communauté.
///
/// TODO (Njoya) : à remplacer/aligner sur le modèle réel une fois l'API
/// branchée — alimentés pour l'instant par
/// datasource/community_members_mock_datasource.dart.

enum MemberRowStatus { upToDate, pending, late }

/// Une ligne de l'annuaire des membres — vue non-admin.
class MemberDirectoryEntry {
  const MemberDirectoryEntry({
    required this.name,
    required this.memberSinceLabel,
    required this.status,
    this.role,
    this.isHighlighted = false,
  });

  final String name;
  final String? role; // 'ADMIN' ou null
  final String memberSinceLabel;
  final MemberRowStatus status;
  final bool isHighlighted; // étoile (membre exemplaire)
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
  });

  final String name;
  final String? role;
  final String statusLine;
  final IconData statusIcon;
  final Color statusColor;
  final bool isHighlighted;
  final bool hasUrgentAction; // affiche l'icône enveloppe au lieu du menu "..."
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