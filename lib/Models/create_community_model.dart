import 'package:flutter/material.dart';

/// Type de communauté (Étape 1/5).
enum CommunityType { famille, amis, entreprise, association, autre }

extension CommunityTypeX on CommunityType {
  IconData get icon => switch (this) {
        CommunityType.famille => Icons.home_outlined,
        CommunityType.amis => Icons.people_outline,
        CommunityType.entreprise => Icons.apartment_outlined,
        CommunityType.association => Icons.groups_outlined,
        CommunityType.autre => Icons.more_horiz,
      };

  String get labelKey => switch (this) {
        CommunityType.famille => 'community_type_family',
        CommunityType.amis => 'community_type_friends',
        CommunityType.entreprise => 'community_type_business',
        CommunityType.association => 'community_type_association',
        CommunityType.autre => 'community_type_other',
      };
}

/// Fréquence de cotisation (Étape 2/5).
enum ContributionFrequency { hebdomadaire, bimensuelle, mensuelle, personnalisee }

extension ContributionFrequencyX on ContributionFrequency {
  String get titleKey => switch (this) {
        ContributionFrequency.hebdomadaire => 'freq_weekly_title',
        ContributionFrequency.bimensuelle => 'freq_biweekly_title',
        ContributionFrequency.mensuelle => 'freq_monthly_title',
        ContributionFrequency.personnalisee => 'freq_custom_title',
      };

  String get subtitleKey => switch (this) {
        ContributionFrequency.hebdomadaire => 'freq_weekly_subtitle',
        ContributionFrequency.bimensuelle => 'freq_biweekly_subtitle',
        ContributionFrequency.mensuelle => 'freq_monthly_subtitle',
        ContributionFrequency.personnalisee => 'freq_custom_subtitle',
      };
}

/// Un membre déjà invité (Étape 4/5).
class InvitedMember {
  const InvitedMember({
    required this.name,
    required this.phone,
    required this.initials,
    required this.avatarBg,
    required this.avatarColor,
  });

  final String name;
  final String phone;
  final String initials;
  final Color avatarBg;
  final Color avatarColor;
}

/// Brouillon de communauté en cours de création — porté d'étape en
/// étape via les arguments de route (voir app_router.dart), rempli
/// progressivement puis (plus tard, une fois l'API branchée) envoyé
/// pour création réelle.
class CommunityDraft {
  const CommunityDraft({
    this.photoPath,
    this.name = '',
    this.description = '',
    this.type,
    this.contributionAmount = '',
    this.frequency,
    this.startDate,
    this.dueDayLabel,
    this.expectedMemberCount = '',
    // Étape 3 — Règles de fonctionnement
    this.allowLoans = true,
    this.maxLoanAmount = '',
    this.maxLoanDurationMonths = '',
    this.maxSimultaneousLoans = '',
    this.adminValidationRequired = true,
    this.penaltiesEnabled = true,
    this.maxAdminCount = 3,
    this.collectiveValidation = true,
    // Étape 4 — Inviter des membres
    this.invitedMembers = const [],
  });

  final String? photoPath;
  final String name;
  final String description;
  final CommunityType? type;
  final String contributionAmount;
  final ContributionFrequency? frequency;
  final DateTime? startDate;
  final String? dueDayLabel;
  final String expectedMemberCount;

  final bool allowLoans;
  final String maxLoanAmount;
  final String maxLoanDurationMonths;
  final String maxSimultaneousLoans;
  final bool adminValidationRequired;
  final bool penaltiesEnabled;
  final int maxAdminCount;
  final bool collectiveValidation;

  final List<InvitedMember> invitedMembers;

  CommunityDraft copyWith({
    String? photoPath,
    String? name,
    String? description,
    CommunityType? type,
    String? contributionAmount,
    ContributionFrequency? frequency,
    DateTime? startDate,
    String? dueDayLabel,
    String? expectedMemberCount,
    bool? allowLoans,
    String? maxLoanAmount,
    String? maxLoanDurationMonths,
    String? maxSimultaneousLoans,
    bool? adminValidationRequired,
    bool? penaltiesEnabled,
    int? maxAdminCount,
    bool? collectiveValidation,
    List<InvitedMember>? invitedMembers,
  }) {
    return CommunityDraft(
      photoPath: photoPath ?? this.photoPath,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      contributionAmount: contributionAmount ?? this.contributionAmount,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      dueDayLabel: dueDayLabel ?? this.dueDayLabel,
      expectedMemberCount: expectedMemberCount ?? this.expectedMemberCount,
      allowLoans: allowLoans ?? this.allowLoans,
      maxLoanAmount: maxLoanAmount ?? this.maxLoanAmount,
      maxLoanDurationMonths: maxLoanDurationMonths ?? this.maxLoanDurationMonths,
      maxSimultaneousLoans: maxSimultaneousLoans ?? this.maxSimultaneousLoans,
      adminValidationRequired: adminValidationRequired ?? this.adminValidationRequired,
      penaltiesEnabled: penaltiesEnabled ?? this.penaltiesEnabled,
      maxAdminCount: maxAdminCount ?? this.maxAdminCount,
      collectiveValidation: collectiveValidation ?? this.collectiveValidation,
      invitedMembers: invitedMembers ?? this.invitedMembers,
    );
  }
}