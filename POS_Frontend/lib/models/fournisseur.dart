// ============================================================================
// Modèle Fournisseur — reflète la table correspondante de schema.sql (PostgreSQL)
// Traduit le JSON renvoyé par l'API Django REST en objet Dart typé, et inversement.
// ============================================================================
class Fournisseur {
  final int idFournisseur;
  final String raisonSociale;
  final String? telephone;
  final String? adresse;
  final String? email;
  final bool actif;

  Fournisseur({
    required this.idFournisseur,
    required this.raisonSociale,
    this.telephone,
    this.adresse,
    this.email,
    required this.actif
  });

  /// Construit un Fournisseur à partir du JSON renvoyé par l'API.
  factory Fournisseur.fromJson(Map<String, dynamic> json) {
    return Fournisseur(
      idFournisseur: json['id_fournisseur'] is int ? json['id_fournisseur'] as int : int.parse(json['id_fournisseur'].toString()),
      raisonSociale: json['raison_sociale'].toString(),
      telephone: json['telephone']?.toString(),
      adresse: json['adresse']?.toString(),
      email: json['email']?.toString(),
      actif: json['actif'] as bool
    );
  }

  /// Transforme ce Fournisseur en JSON pour l'envoyer à l'API (POST/PUT).
  Map<String, dynamic> toJson() {
    return {
      'id_fournisseur': idFournisseur,
      'raison_sociale': raisonSociale,
      'telephone': telephone,
      'adresse': adresse,
      'email': email,
      'actif': actif
    };
  }
}
