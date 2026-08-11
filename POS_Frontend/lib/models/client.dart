// ============================================================================
// Modèle Client — reflète la table correspondante de schema.sql (PostgreSQL)
// Traduit le JSON renvoyé par l'API Django REST en objet Dart typé, et inversement.
// ============================================================================
class Client {
  final int idClient;
  final String nom;
  final String? prenom;
  final String? telephone;
  final String? email;
  final String? adresse;
  final bool actif;

  String get nomComplet => '$nom ${prenom ?? ''}'.trim();

  Client({
    required this.idClient,
    required this.nom,
    this.prenom,
    this.telephone,
    this.email,
    this.adresse,
    required this.actif
  });

  /// Construit un Client à partir du JSON renvoyé par l'API.
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      idClient: json['id_client'] is int ? json['id_client'] as int : int.parse(json['id_client'].toString()),
      nom: json['nom'].toString(),
      prenom: json['prenom']?.toString(),
      telephone: json['telephone']?.toString(),
      email: json['email']?.toString(),
      adresse: json['adresse']?.toString(),
      actif: json['actif'] as bool
    );
  }

  /// Payload POST/PUT — sans `id_client` (auto-généré à la création).
  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'email': email,
      'adresse': adresse,
      'actif': actif,
    };
  }
}
