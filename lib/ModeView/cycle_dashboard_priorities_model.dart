class CycleDashboardPriorities {
  const CycleDashboardPriorities({
    required this.pendingTontineContributions,
    required this.pendingLoanRequests,
    required this.overdueMembers,
    this.currentTourDueDate,
    this.overdueMemberList = const [],
    this.groupHealthScore,
    this.membersUpToDate,
    this.membersPending,
    this.membersOverdue,
    this.totalMembers,
    this.activeLoans,
    this.pendingContributions,
  });

  final int pendingTontineContributions;
  final int pendingLoanRequests;
  final int overdueMembers;
  final DateTime? currentTourDueDate;
  final List<OverdueCycleMember> overdueMemberList;
  final int? groupHealthScore;
  final int? membersUpToDate;
  final int? membersPending;
  final int? membersOverdue;
  final int? totalMembers;
  final int? activeLoans;
  final int? pendingContributions;

  factory CycleDashboardPriorities.fromJson(Map<String, dynamic> json) {
    return CycleDashboardPriorities(
      pendingTontineContributions: _requiredInt(
        json['cotisations_en_attente'],
        'cotisations_en_attente',
      ),
      pendingLoanRequests: _requiredInt(
        json['demandes_pret_en_attente'],
        'demandes_pret_en_attente',
      ),
      overdueMembers: _requiredInt(
        json['membres_en_retard'],
        'membres_en_retard',
      ),
      currentTourDueDate: _date(json['date_echeance_tour_courant']),
      overdueMemberList: _overdueMembers(json['membres_en_retard_liste']),
      groupHealthScore: _healthMetric(json, 'sante_groupe', 'score'),
      membersUpToDate: _healthMetric(json, 'sante_groupe', 'membres_a_jour'),
      membersPending: _healthMetric(json, 'sante_groupe', 'membres_en_attente'),
      membersOverdue: _healthMetric(json, 'sante_groupe', 'membres_en_retard'),
      totalMembers: _healthMetric(json, 'sante_groupe', 'membres_total'),
      activeLoans: _healthMetric(json, 'sante_groupe', 'prets_actifs'),
      pendingContributions: _healthMetric(
        json,
        'sante_groupe',
        'cotisations_en_attente',
      ),
    );
  }
}

class CycleGroupHealth {
  const CycleGroupHealth({
    required this.score,
    required this.membersUpToDate,
    required this.totalMembers,
    required this.activeLoans,
    required this.pendingContributions,
    required this.membersPending,
    required this.membersOverdue,
  });

  final int? score;
  final int membersUpToDate;
  final int totalMembers;
  final int activeLoans;
  final int pendingContributions;
  final int membersPending;
  final int membersOverdue;

  factory CycleGroupHealth.fromJson(Map<String, dynamic> json) {
    final score =
        json['score'] == null ? null : _requiredInt(json['score'], 'score');
    return CycleGroupHealth(
      score: score,
      membersUpToDate: _requiredInt(json['membres_a_jour'], 'membres_a_jour'),
      totalMembers: _requiredInt(json['membres_total'], 'membres_total'),
      activeLoans: _requiredInt(json['prets_actifs'], 'prets_actifs'),
      pendingContributions: _requiredInt(
        json['cotisations_en_attente'],
        'cotisations_en_attente',
      ),
      membersPending: _requiredInt(
        json['membres_en_attente'],
        'membres_en_attente',
      ),
      membersOverdue: _requiredInt(
        json['membres_en_retard'],
        'membres_en_retard',
      ),
    );
  }
}

int? _healthMetric(
  Map<String, dynamic> json,
  String parentField,
  String field,
) {
  final health = json[parentField];
  if (health is! Map || !health.containsKey(field)) return null;
  final value = health[field];
  if (value == null && field == 'score') return null;
  return _requiredInt(value, '$parentField.$field');
}

class OverdueCycleMember {
  const OverdueCycleMember({required this.id, required this.name});

  final String id;
  final String name;

  factory OverdueCycleMember.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final name = json['nom']?.toString().trim() ?? '';
    if (id.isEmpty || name.isEmpty) {
      throw const FormatException('Invalid overdue cycle member');
    }
    return OverdueCycleMember(id: id, name: name);
  }
}

class PendingTontineContribution {
  const PendingTontineContribution({
    required this.id,
    required this.memberName,
    required this.amount,
    this.period,
    this.operationDate,
    this.paymentMethod,
    this.operator,
    this.paymentReference,
    this.receiptPath,
    this.isSimulation = false,
  });

  final String id;
  final String memberName;
  final num amount;
  final String? period;
  final DateTime? operationDate;
  final String? paymentMethod;
  final String? operator;
  final String? paymentReference;
  final String? receiptPath;
  final bool isSimulation;

  factory PendingTontineContribution.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final amount = _number(json['montant']);
    final member =
        json['membre'] is Map
            ? Map<String, dynamic>.from(json['membre'] as Map)
            : const <String, dynamic>{};
    final user =
        member['utilisateur'] is Map
            ? Map<String, dynamic>.from(member['utilisateur'] as Map)
            : const <String, dynamic>{};
    final userName = [
      user['prenom']?.toString().trim() ?? '',
      user['nom']?.toString().trim() ?? '',
    ].where((part) => part.isNotEmpty).join(' ');
    final memberName =
        userName.isNotEmpty
            ? userName
            : member['utilisateur_nom']?.toString().trim() ?? '';
    if (id.isEmpty || amount == null) {
      throw const FormatException('Invalid pending tontine contribution');
    }

    return PendingTontineContribution(
      id: id,
      memberName: memberName,
      amount: amount,
      period: _optionalString(json['periode']),
      operationDate: _date(json['date_operation'] ?? json['created_at']),
      paymentMethod: _optionalString(json['mode_paiement']),
      operator: _optionalString(json['operateur']),
      paymentReference: _optionalString(json['reference_paiement']),
      receiptPath: _optionalString(json['preuve_paiement']),
      isSimulation: _boolean(json['is_simulation']),
    );
  }
}

class PendingLoanRequest {
  const PendingLoanRequest({
    required this.id,
    required this.memberName,
    required this.amount,
    this.reason,
    this.createdAt,
    this.repaymentDate,
  });

  final String id;
  final String memberName;
  final num amount;
  final String? reason;
  final DateTime? createdAt;
  final DateTime? repaymentDate;

  factory PendingLoanRequest.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final amount = _number(json['montant_demande']);
    if (id.isEmpty || amount == null) {
      throw const FormatException('Invalid pending loan request');
    }

    return PendingLoanRequest(
      id: id,
      memberName: json['membre_groupe_name']?.toString().trim() ?? '',
      amount: amount,
      reason: _optionalString(json['motif']),
      createdAt: _date(json['created_at']),
      repaymentDate: _date(json['date_remboursement_souhaitee']),
    );
  }
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.length < 10 ? null : DateTime.tryParse(text.substring(0, 10));
}

num? _number(dynamic value) =>
    value is num ? value : num.tryParse(value?.toString() ?? '');

bool _boolean(dynamic value) =>
    value == true || value == 1 || value?.toString().toLowerCase() == 'true';

String? _optionalString(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

List<OverdueCycleMember> _overdueMembers(dynamic value) {
  if (value == null) return const [];
  if (value is! List) {
    throw const FormatException('Invalid overdue cycle member list');
  }
  return value
      .whereType<Map>()
      .map(
        (member) =>
            OverdueCycleMember.fromJson(Map<String, dynamic>.from(member)),
      )
      .toList(growable: false);
}

int _requiredInt(dynamic value, String field) {
  final parsed = value is num ? value.toInt() : int.tryParse('$value');
  if (parsed == null || parsed < 0) {
    throw FormatException('Invalid cycle dashboard priority: $field');
  }
  return parsed;
}
