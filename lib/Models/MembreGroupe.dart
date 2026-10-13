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
    this.telephone,
    this.email,
    this.sexe,
    this.photo,
    this.adresse,
    this.ville,
    this.pays,
    this.cniRecto,
    this.cniVerso,
    this.passport,
    this.permis,
    this.utilisateurCreatedAt,
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
  final String? telephone;
  final String? email;
  final String? sexe;
  final String? photo;
  final String? adresse;
  final String? ville;
  final String? pays;
  final String? cniRecto;
  final String? cniVerso;
  final String? passport;
  final String? permis;
  final String? utilisateurCreatedAt;

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
    String? userField(String key, [String? alternate]) =>
        utilisateurJson?[key]?.toString() ??
        (alternate == null ? null : utilisateurJson?[alternate]?.toString()) ??
        json['utilisateur_$key']?.toString() ??
        json[key]?.toString();

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
      telephone: userField('telephone', 'phone'),
      email: userField('email'),
      sexe: userField('sexe', 'gender'),
      photo: userField('photo', 'photo_url'),
      adresse: userField('adresse', 'address'),
      ville: userField('ville', 'city'),
      pays: userField('pays', 'country'),
      cniRecto: userField('cni_recto'),
      cniVerso: userField('cni_verso'),
      passport: userField('passport'),
      permis:
          userField('permis') ??
          userField('permis_conduire') ??
          userField('driving_license'),
      utilisateurCreatedAt: userField('created_at'),
    );
  }
}
