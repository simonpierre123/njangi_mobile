class Cycle {
  const Cycle({
    this.id,
    this.groupId,
    this.groupName,
    this.groupDescription,
    this.groupType,
    this.groupCode,
    this.number,
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
    this.deleted = '0',
  });

  final String? id;
  final String? groupId;
  final String? groupName;
  final String? groupDescription;
  final String? groupType;
  final String? groupCode;
  final int? number;
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
      loanModuleActive: json['module_pret_actif']?.toString() ?? '1',
      collectiveLoanValidation:
          json['validation_pret_colectif']?.toString() ?? '1',
      penaltiesEnabled: json['appliquer_penalites']?.toString() ?? '1',
      deleted: json['delete']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toCreateJson() => {
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
    'module_pret_actif': loanModuleActive,
    'validation_pret_colectif': collectiveLoanValidation,
    'appliquer_penalites': penaltiesEnabled,
  };
}

int? _toInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');

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
