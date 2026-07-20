import 'package:flutter/material.dart';

/// Statut visuel d'un badge de communauté.
enum CommunityBadgeType { info, warning, none }

/// Modèle de données pour une communauté affichée sur le tableau de bord.
///
/// TODO (Njoya) : à remplacer/aligner sur le modèle réel une fois l'API
/// branchée — ces champs ne servent aujourd'hui qu'à l'affichage des
/// cards avec des données mock (voir datasource/community_mock_datasource.dart).
class CommunityModel {
  const CommunityModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.cycleCurrent,
    required this.cycleTotal,
    required this.memberCount,
    required this.contributionAmount,
    required this.contributionFrequency,
    required this.progressPercent,
    required this.lastUpdateLabel,
    this.role,
    this.badgeLabel,
    this.badgeType = CommunityBadgeType.none,
    this.statusLabel,
    this.actionLabel,
  });

  final String id;
  final String name;
  final IconData icon;
  final String? role;
  final int cycleCurrent;
  final int cycleTotal;
  final int memberCount;
  final String contributionAmount;
  final String contributionFrequency;
  final double progressPercent; // 0.0 à 1.0
  final String lastUpdateLabel;
  final String? badgeLabel;
  final CommunityBadgeType badgeType;
  final String? statusLabel;
  final String? actionLabel;
}