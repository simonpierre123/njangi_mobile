class MembreGroupeCycle {
  const MembreGroupeCycle({
    required this.id,
    required this.utilisateurId,
    required this.groupeId,
    required this.cycleId,
    required this.role,
    this.utilisateurNom,
    this.groupeNom,
    this.cycleNom,
    this.dateAdhesion,
    this.statut,
    this.active = '1',
  });

  final String id;
  final String utilisateurId;
  final String groupeId;
  final String cycleId;
  final String role;
  final String? utilisateurNom;
  final String? groupeNom;
  final String? cycleNom;
  final String? dateAdhesion;
  final String? statut;
  final String active;

  factory MembreGroupeCycle.fromJson(Map<String, dynamic> json) {
    return MembreGroupeCycle(
      id: json['id']?.toString() ?? '',
      utilisateurId: json['utilisateur_id']?.toString() ?? '',
      groupeId: json['groupe_id']?.toString() ?? '',
      cycleId: json['cycle_id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'MEMBRE',
      utilisateurNom: json['utilisateur_nom']?.toString(),
      groupeNom: json['groupe_nom']?.toString(),
      cycleNom: json['cycle_nom']?.toString(),
      dateAdhesion: json['date_adhesion']?.toString(),
      statut: json['statut']?.toString(),
      active: json['active']?.toString() ?? '1',
    );
  }
}
