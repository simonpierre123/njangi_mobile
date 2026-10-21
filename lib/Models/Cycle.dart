class Cycle {
  const Cycle({
    this.id,
    this.groupId,
    this.groupName,
    this.groupDescription,
    this.groupType,
    this.groupCode,
    this.number,
    this.cycleName,
    this.memberCount,
    this.adminCount,
    this.contributionAmount,
    this.currency = 'XAF',
    this.maxLoanAmount,
    this.maxLoanDuration,
    this.maxSimultaneousLoans,
    this.frequency,
    this.dueDay,
    this.startDate,
    this.endDate,
    this.status,
    this.loanModuleActive = '1',
    this.collectiveLoanValidation = '1',
    this.penaltiesEnabled = '1',
    this.savingsActive = false,
    this.savingsMode,
    this.savingsFixedAmount,
    this.savingsMinAmount,
    this.savingsMaxAmount,
    this.savingsCalendarMode = 'MEME_QUE_TONTINE',
    this.savingsFrequency,
    this.savingsDueDay,
    this.emergencyFundActive = false,
    this.emergencyIncludeBeneficiary = true,
    this.tontineActive = true,
    this.tontineNextVisible = false,
    this.deleted = '0',
  });

  final String? id;
  final String? groupId;
  final String? groupName;
  final String? groupDescription;
  final String? groupType;
  final String? groupCode;
  final int? number;
  final String? cycleName;
  final int? memberCount;
  final int? adminCount;
  final int? contributionAmount;
  final String? currency;
  final int? maxLoanAmount;
  final int? maxLoanDuration;
  final int? maxSimultaneousLoans;
  final String? frequency;
  final String? dueDay;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final String loanModuleActive;
  final String collectiveLoanValidation;
  final String penaltiesEnabled;
  final bool savingsActive;
  final String? savingsMode;
  final int? savingsFixedAmount;
  final int? savingsMinAmount;
  final int? savingsMaxAmount;
  final String savingsCalendarMode;
  final String? savingsFrequency;
  final String? savingsDueDay;
  final bool emergencyFundActive;
  final bool emergencyIncludeBeneficiary;
  final bool tontineActive;
  final bool tontineNextVisible;
  final String deleted;

  factory Cycle.fromJson(Map<String, dynamic> json) {
    final group = json['groupe'];
    final groupData = group is Map ? Map<String, dynamic>.from(group) : null;
    return Cycle(
      id: json['id']?.toString(),
      groupId: json['groupe_id']?.toString(),
      groupName: json['groupe_nom']?.toString(),
      groupDescription: groupData?['description']?.toString(),
      groupType: groupData?['type']?.toString(),
      groupCode: groupData?['code_groupe']?.toString(),
      number: _toInt(json['numero']),
      cycleName: json['nom']?.toString(),
      memberCount: _toInt(json['nombre_membres']),
      adminCount: _toInt(json['nombre_admin']),
      contributionAmount: _toInt(json['montant_cotisation']),
      currency: json['devise']?.toString() ?? 'XAF',
      maxLoanAmount: _toInt(json['montant_max_pret']),
      maxLoanDuration: _toInt(json['duree_max_pret']),
      maxSimultaneousLoans: _toInt(json['nombre_max_pret_simultane']),
      frequency: json['frequence_cycle']?.toString(),
      dueDay: json['jour_echeance']?.toString(),
      startDate: _toDate(json['date_debut']),
      endDate: _toDate(json['date_fin']),
      status: json['statut']?.toString(),
      loanModuleActive:
          (_toBool(json['module_pret_actif']) ?? true) ? '1' : '0',
      collectiveLoanValidation:
          json['validation_pret_colectif']?.toString() ?? '1',
      penaltiesEnabled: json['appliquer_penalites']?.toString() ?? '1',
      savingsActive: _toBool(json['epargne_active']) ?? false,
      savingsMode: json['epargne_mode']?.toString(),
      savingsFixedAmount: _toInt(json['epargne_montant_fixe']),
      savingsMinAmount: _toInt(json['epargne_montant_min']),
      savingsMaxAmount: _toInt(json['epargne_montant_max']),
      savingsCalendarMode:
          json['epargne_calendrier_mode']?.toString() ?? 'MEME_QUE_TONTINE',
      savingsFrequency: json['epargne_frequence']?.toString(),
      savingsDueDay: json['epargne_jour_echeance']?.toString(),
      emergencyFundActive: _toBool(json['caisse_secours_active']) ?? false,
      emergencyIncludeBeneficiary:
          _toBool(json['secours_inclure_beneficiaire']) ?? true,
      tontineActive: _toBool(json['tontine_active']) ?? true,
      tontineNextVisible: _toBool(json['tontine_prochain_visible']) ?? false,
      deleted: json['delete']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toCreateJson() => {
    'numero': number ?? 1,
    'nom': cycleName ?? 'Cycle 1',
    'nombre_membres': memberCount,
    'nombre_admin': adminCount,
    'montant_cotisation': contributionAmount,
    'devise': currency,
    'montant_max_pret': maxLoanAmount,
    'duree_max_pret': maxLoanDuration,
    'nombre_max_pret_simultane': maxSimultaneousLoans,
    'frequence_cycle': frequency,
    'jour_echeance': dueDay,
    'date_debut': _formatDate(startDate),
    'date_fin': _formatDate(endDate),
    'statut': status ?? 'EN_ATTENTE',
    'module_pret_actif': loanModuleActive == '1',
    'validation_pret_colectif': collectiveLoanValidation,
    'appliquer_penalites': penaltiesEnabled,
    'epargne_active': savingsActive,
    'epargne_mode': savingsMode,
    'epargne_montant_fixe': savingsFixedAmount,
    'epargne_montant_min': savingsMinAmount,
    'epargne_montant_max': savingsMaxAmount,
    'epargne_calendrier_mode': savingsCalendarMode,
    'epargne_frequence': savingsFrequency,
    'epargne_jour_echeance': savingsDueDay,
    'caisse_secours_active': emergencyFundActive,
    'secours_inclure_beneficiaire': emergencyIncludeBeneficiary,
    'tontine_active': tontineActive,
    'tontine_prochain_visible': tontineNextVisible,
  };
}

int? _toInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');

bool? _toBool(dynamic value) => switch (value) {
  bool value => value,
  num value => value != 0,
  String value => switch (value.toLowerCase()) {
    '1' || 'true' => true,
    '0' || 'false' => false,
    _ => null,
  },
  _ => null,
};

DateTime? _toDate(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String? _formatDate(DateTime? value) {
  if (value == null) return null;
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
