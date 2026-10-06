class MembreGroupe {
  const MembreGroupe({
    required this.id,
    required this.utilisateurId,
    required this.groupeId,
    required this.role,
    required this.statut,
    required this.active,
    this.utilisateurNom,
    this.utilisateurPrenom,
    this.groupeNom,
    this.dateAdhesion,
  });

  final String id;
  final String utilisateurId;
  final String groupeId;
  final String role;
  final String statut;
  final String active;
  final String? utilisateurNom;
  final String? utilisateurPrenom;
  final String? groupeNom;
  final String? dateAdhesion;

  String get displayName {
    final parts =
        [utilisateurPrenom, utilisateurNom]
            .whereType<String>()
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList();
    return parts.isEmpty ? utilisateurId : parts.join(' ');
  }

  factory MembreGroupe.fromJson(Map<String, dynamic> json) {
    final utilisateur = json['utilisateur'];
    final utilisateurJson =
        utilisateur is Map ? Map<String, dynamic>.from(utilisateur) : null;
    return MembreGroupe(
      id: json['id']?.toString() ?? '',
      utilisateurId: json['utilisateur_id']?.toString() ?? '',
      groupeId: json['groupe_id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'MEMBRE',
      statut: json['statut']?.toString() ?? 'ACTIF',
      active: json['active']?.toString() ?? '1',
      utilisateurNom:
          json['utilisateur_nom']?.toString() ??
          utilisateurJson?['nom']?.toString(),
      utilisateurPrenom: utilisateurJson?['prenom']?.toString(),
      groupeNom: json['groupe_nom']?.toString(),
      dateAdhesion: json['date_adhesion']?.toString(),
    );
  }
}
