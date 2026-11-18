import 'package:flutter/material.dart';

/// Modèles pour l'onglet "Membres" d'une communauté.
///
/// Modèles de l'annuaire des membres et de leur conformité financière au
/// tour courant du cycle.

enum MemberRowStatus { upToDate, pending, late, unknown }

class MemberComplianceDetails {
  const MemberComplianceDetails({
    required this.isUpToDate,
    required this.contributionValidated,
    required this.contributionStatus,
    required this.currency,
    this.totalTontineContribution = 0,
    this.currentPeriod,
    this.currentDueDate,
    this.loans = const [],
  });

  final bool isUpToDate;
  final bool contributionValidated;
  final String contributionStatus;
  final String currency;
  final int totalTontineContribution;
  final String? currentPeriod;
  final String? currentDueDate;
  final List<MemberLoanCompliance> loans;

  factory MemberComplianceDetails.fromJson(
    Map<String, dynamic> json, {
    required String currency,
    String? currentPeriod,
    String? currentDueDate,
  }) {
    final loansJson = json['prets_a_rembourser'];
    if (loansJson is! List) {
      throw const FormatException('Invalid member loan compliance list');
    }

    return MemberComplianceDetails(
      isUpToDate: _boolean(json['est_a_jour'], 'est_a_jour'),
      contributionValidated: _boolean(
        json['cotisation_validee'],
        'cotisation_validee',
      ),
      contributionStatus: json['cotisation_statut']?.toString() ?? 'AUCUNE',
      currency: currency,
      totalTontineContribution:
          int.tryParse(json['total_cotise_tontine']?.toString() ?? '') ?? 0,
      currentPeriod: currentPeriod,
      currentDueDate: currentDueDate,
      loans: loansJson
          .whereType<Map>()
          .map(
            (loan) => MemberLoanCompliance.fromJson(
              Map<String, dynamic>.from(loan),
            ),
          )
          .toList(growable: false),
    );
  }
}

class CycleMemberCompliance {
  const CycleMemberCompliance({
    required this.membershipId,
    required this.userId,
    required this.name,
    required this.role,
    required this.isUpToDate,
    required this.compliance,
    this.memberSince,
    this.photoUrl,
  });

  final String membershipId;
  final String userId;
  final String name;
  final String role;
  final bool isUpToDate;
  final String? memberSince;
  final String? photoUrl;
  final MemberComplianceDetails compliance;

  factory CycleMemberCompliance.fromJson(
    Map<String, dynamic> json, {
    required String currency,
    String? currentPeriod,
    String? currentDueDate,
  }) {
    final membershipId = json['id']?.toString() ?? '';
    final userId = json['utilisateur_id']?.toString() ?? '';
    final name = json['nom']?.toString().trim() ?? '';
    if (membershipId.isEmpty || userId.isEmpty || name.isEmpty) {
      throw const FormatException('Invalid cycle member compliance record');
    }

    return CycleMemberCompliance(
      membershipId: membershipId,
      userId: userId,
      name: name,
      role: json['role']?.toString() ?? 'MEMBRE',
      isUpToDate: _boolean(json['est_a_jour'], 'est_a_jour'),
      memberSince: json['date_adhesion']?.toString(),
      photoUrl: json['photo']?.toString(),
      compliance: MemberComplianceDetails.fromJson(
        json,
        currency: currency,
        currentPeriod: currentPeriod,
        currentDueDate: currentDueDate,
      ),
    );
  }
}

class CycleMemberComplianceOverview {
  const CycleMemberComplianceOverview({
    required this.cycleId,
    required this.currency,
    required this.members,
    this.currentPeriod,
    this.currentDueDate,
  });

  final String cycleId;
  final String currency;
  final String? currentPeriod;
  final String? currentDueDate;
  final List<CycleMemberCompliance> members;

  factory CycleMemberComplianceOverview.fromJson(
    Map<String, dynamic> json,
  ) {
    final cycleId = json['cycle_id']?.toString() ?? '';
    if (cycleId.isEmpty || json['membres'] is! List) {
      throw const FormatException('Invalid cycle member compliance overview');
    }

    final tour = json['tour_courant'];
    final tourJson = tour is Map ? Map<String, dynamic>.from(tour) : null;
    final currentPeriod = tourJson?['periode']?.toString();
    final currentDueDate = tourJson?['date_echeance']?.toString();
    final currency = json['devise']?.toString() ?? 'XAF';

    return CycleMemberComplianceOverview(
      cycleId: cycleId,
      currency: currency,
      currentPeriod: currentPeriod,
      currentDueDate: currentDueDate,
      members: (json['membres'] as List)
          .whereType<Map>()
          .map(
            (member) => CycleMemberCompliance.fromJson(
              Map<String, dynamic>.from(member),
              currency: currency,
              currentPeriod: currentPeriod,
              currentDueDate: currentDueDate,
            ),
          )
          .toList(growable: false),
    );
  }
}

class MemberLoanCompliance {
  const MemberLoanCompliance({
    required this.id,
    required this.remainingAmount,
    this.repaymentDate,
  });

  final String id;
  final int remainingAmount;
  final String? repaymentDate;

  factory MemberLoanCompliance.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final remainingAmount = int.tryParse('${json['solde_restant']}');
    if (id.isEmpty || remainingAmount == null || remainingAmount <= 0) {
      throw const FormatException('Invalid outstanding cycle loan');
    }

    return MemberLoanCompliance(
      id: id,
      remainingAmount: remainingAmount,
      repaymentDate: json['date_remboursement_souhaitee']?.toString(),
    );
  }
}

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
    this.compliance,
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
  final MemberComplianceDetails? compliance;

  MemberPersonalDetails copyWith({
    String? role,
    MemberComplianceDetails? compliance,
  }) => MemberPersonalDetails(
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
    compliance: compliance ?? this.compliance,
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
  const TrustScore({
    required this.percent,
    required this.summary,
    this.isAvailable = true,
  });

  final double percent; // 0.0 à 1.0
  final String summary;
  final bool isAvailable;
}

bool _boolean(dynamic value, String field) {
  if (value is bool) return value;
  if (value == 1 || value?.toString() == '1' || value?.toString() == 'true') {
    return true;
  }
  if (value == 0 || value?.toString() == '0' || value?.toString() == 'false') {
    return false;
  }
  throw FormatException('Invalid boolean value for $field');
}

/// Croissance mensuelle du groupe — vue admin.
class GrowthStats {
  const GrowthStats({required this.newMembersLabel, required this.percent});

  final String newMembersLabel;
  final double percent; // 0.0 à 1.0
}
