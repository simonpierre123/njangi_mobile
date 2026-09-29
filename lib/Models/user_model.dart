class UserModel {
  final String id;
  final String? nom;
  final String? prenom;
  final String telephone;
  final String? sexe;
  final String? photo;
  final String? email;
  final String? cniRecto;
  final String? cniVerso;
  final String? pays;
  final String? ville;
  final String? adresse;
  final int statut;
  final String active;
  final String delete;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    this.nom,
    this.prenom,
    required this.telephone,
    this.sexe,
    this.photo,
    this.email,
    this.cniRecto,
    this.cniVerso,
    this.pays,
    this.ville,
    this.adresse,
    required this.statut,
    required this.active,
    required this.delete,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      telephone: json['telephone'] as String,
      sexe: json['sexe'] as String?,
      photo: json['photo'] as String?,
      email: json['email'] as String?,
      cniRecto: json['cni_recto'] as String?,
      cniVerso: json['cni_verso'] as String?,
      pays: json['pays'] as String?,
      ville: json['ville'] as String?,
      adresse: json['adresse'] as String?,
      statut:
          json['statut'] is int
              ? json['statut']
              : int.parse(json['statut'].toString()),
      active: json['active']?.toString() ?? '1',
      delete: json['delete']?.toString() ?? '0',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'sexe': sexe,
      'photo': photo,
      'email': email,
      'cni_recto': cniRecto,
      'cni_verso': cniVerso,
      'pays': pays,
      'ville': ville,
      'adresse': adresse,
      'statut': statut,
      'active': active,
      'delete': delete,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
