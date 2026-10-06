class GroupeNjangi {
  const GroupeNjangi({
    required this.id,
    required this.nom,
    required this.description,
    required this.type,
    required this.active,
    required this.codeGroupe,
    this.logo,
  });

  final String id;
  final String nom;
  final String description;
  final String type;
  final String active;
  final String codeGroupe;
  final String? logo;

  factory GroupeNjangi.fromJson(Map<String, dynamic> json) {
    return GroupeNjangi(
      id: json['id']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      active: json['active']?.toString() ?? '1',
      codeGroupe: json['code_groupe']?.toString() ?? '',
      logo: json['logo']?.toString(),
    );
  }
}
