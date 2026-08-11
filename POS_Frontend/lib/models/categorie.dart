class Categorie {
  final int idCategorie;
  final String nom;
  final String? description;
  final bool actif;
  final int nombreProduits;

  Categorie({
    required this.idCategorie,
    required this.nom,
    this.description,
    required this.actif,
    this.nombreProduits = 0,
  });

  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      idCategorie: json['id_categorie'] is int
          ? json['id_categorie'] as int
          : int.parse(json['id_categorie'].toString()),
      nom: json['nom'].toString(),
      description: json['description']?.toString(),
      actif: json['actif'] == true || json['actif']?.toString() == 'true',
      nombreProduits: json['nombre_produits'] is num
          ? (json['nombre_produits'] as num).toInt()
          : int.tryParse(json['nombre_produits']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'description': description,
      'actif': actif,
    };
  }

  Categorie copyWith({
    int? idCategorie,
    String? nom,
    String? description,
    bool? actif,
    int? nombreProduits,
  }) {
    return Categorie(
      idCategorie: idCategorie ?? this.idCategorie,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      actif: actif ?? this.actif,
      nombreProduits: nombreProduits ?? this.nombreProduits,
    );
  }
}
