import 'package:flutter/material.dart';
import '../Models/MembreGroupe.dart';

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
    this.description = '',
    this.type = '',
    this.groupCode,
    this.members = const [],
    this.membersLoaded = false,
    this.cyclesLoaded = false,
    this.cycleId,
    this.hasCycle = true,
    this.tontineNextVisible = false,
    this.meetingDay,
    this.logoUrl,
    this.role,
    this.badgeLabel,
    this.badgeType = CommunityBadgeType.none,
    this.statusLabel,
    this.actionLabel,
  });

  final String id;
  final String name;
  final String description;
  final String type;
  final String? groupCode;
  final IconData icon;
  final String? role;
  final int cycleCurrent;
  final int cycleTotal;
  final int memberCount;
  final List<MembreGroupe> members;
  final bool membersLoaded;
  final bool cyclesLoaded;
  final String? cycleId;
  final bool hasCycle;
  final bool tontineNextVisible;
  final String contributionAmount;
  final String contributionFrequency;
  final String? meetingDay;
  final String? logoUrl;
  final double progressPercent; // 0.0 à 1.0
  final String lastUpdateLabel;
  final String? badgeLabel;
  final CommunityBadgeType badgeType;
  final String? statusLabel;
  final String? actionLabel;

  CommunityModel copyWith({
    String? name,
    String? description,
    String? type,
    String? groupCode,
    IconData? icon,
    String? role,
    int? cycleCurrent,
    int? cycleTotal,
    int? memberCount,
    List<MembreGroupe>? members,
    bool? membersLoaded,
    bool? cyclesLoaded,
    String? cycleId,
    bool? hasCycle,
    bool? tontineNextVisible,
    String? contributionAmount,
    String? contributionFrequency,
    String? meetingDay,
    String? logoUrl,
    double? progressPercent,
    String? lastUpdateLabel,
    String? badgeLabel,
    CommunityBadgeType? badgeType,
    String? statusLabel,
    String? actionLabel,
  }) {
    return CommunityModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      groupCode: groupCode ?? this.groupCode,
      icon: icon ?? this.icon,
      role: role ?? this.role,
      cycleCurrent: cycleCurrent ?? this.cycleCurrent,
      cycleTotal: cycleTotal ?? this.cycleTotal,
      memberCount: memberCount ?? this.memberCount,
      members: members ?? this.members,
      membersLoaded: membersLoaded ?? this.membersLoaded,
      cyclesLoaded: cyclesLoaded ?? this.cyclesLoaded,
      cycleId: cycleId ?? this.cycleId,
      hasCycle: hasCycle ?? this.hasCycle,
      tontineNextVisible: tontineNextVisible ?? this.tontineNextVisible,
      contributionAmount: contributionAmount ?? this.contributionAmount,
      contributionFrequency:
          contributionFrequency ?? this.contributionFrequency,
      meetingDay: meetingDay ?? this.meetingDay,
      logoUrl: logoUrl ?? this.logoUrl,
      progressPercent: progressPercent ?? this.progressPercent,
      lastUpdateLabel: lastUpdateLabel ?? this.lastUpdateLabel,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      badgeType: badgeType ?? this.badgeType,
      statusLabel: statusLabel ?? this.statusLabel,
      actionLabel: actionLabel ?? this.actionLabel,
    );
  }
}
