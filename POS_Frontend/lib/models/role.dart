// ============================================================================
// Modèle Role — reflète la table correspondante de schema.sql (PostgreSQL)
// Traduit le JSON renvoyé par l'API Django REST en objet Dart typé, et inversement.
// ============================================================================
class Role {
  final int idRole;
  final String nomRole;
  final String? description;
  final bool actif;

  Role({
    required this.idRole,
    required this.nomRole,
    this.description,
    required this.actif
  });

  /// Construit un Role à partir du JSON renvoyé par l'API.
  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      idRole: json['id_role'] is int
          ? json['id_role'] as int
          : int.parse(json['id_role'].toString()),
      nomRole: json['nom_role'].toString(),
      description: json['description']?.toString(),
      actif: json['actif'] == true || json['actif'] == 1,
    );
  }

  /// Transforme ce Role en JSON pour l'envoyer à l'API (POST/PUT).
  Map<String, dynamic> toJson() {
    return {
      'id_role': idRole,
      'nom_role': nomRole,
      'description': description,
      'actif': actif
    };
  }
}
