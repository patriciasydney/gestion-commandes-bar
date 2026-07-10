// ============================================================================
// Modèle Categorie — reflète la table correspondante de schema.sql (PostgreSQL)
// Traduit le JSON renvoyé par l'API Django REST en objet Dart typé, et inversement.
// ============================================================================
class Categorie {
  final int idCategorie;
  final String nom;
  final String? description;
  final bool actif;

  Categorie({
    required this.idCategorie,
    required this.nom,
    this.description,
    required this.actif
  });

  /// Construit un Categorie à partir du JSON renvoyé par l'API.
  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      idCategorie: json['id_categorie'] is int ? json['id_categorie'] as int : int.parse(json['id_categorie'].toString()),
      nom: json['nom'].toString(),
      description: json['description']?.toString(),
      actif: json['actif'] as bool
    );
  }

  /// Transforme ce Categorie en JSON pour l'envoyer à l'API (POST/PUT).
  Map<String, dynamic> toJson() {
    return {
      'id_categorie': idCategorie,
      'nom': nom,
      'description': description,
      'actif': actif
    };
  }
}
