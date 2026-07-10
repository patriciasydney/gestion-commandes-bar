import '../core/utils/json_parse.dart';

/// Aligné sur `ProduitSerializer` (DRF).
class Produit {
  final int idProduit;
  final String code;
  final String? codeBarres;
  final String nom;
  final String? description;
  final double prixAchat;
  final double prixVente;
  final String? contenance;
  final int stockMinimum;
  final bool actif;
  /// FK `categorie` exposée par le backend.
  final int categorie;
  /// FK `fournisseur` exposée par le backend (nullable).
  final int? fournisseur;
  /// Chemin ou URL `image` (backend), pas de base64 en production.
  final String? image;
  final DateTime? dateCreation;

  Produit({
    required this.idProduit,
    required this.code,
    this.codeBarres,
    required this.nom,
    this.description,
    required this.prixAchat,
    required this.prixVente,
    this.contenance,
    required this.stockMinimum,
    required this.actif,
    required this.categorie,
    this.fournisseur,
    this.image,
    this.dateCreation,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      idProduit: parseFkId(json['id_produit']),
      code: json['code'].toString(),
      codeBarres: json['code_barres']?.toString(),
      nom: json['nom'].toString(),
      description: json['description']?.toString(),
      prixAchat: double.parse(json['prix_achat'].toString()),
      prixVente: double.parse(json['prix_vente'].toString()),
      contenance: json['contenance']?.toString(),
      stockMinimum: parseFkId(json['stock_minimum']),
      actif: json['actif'] as bool,
      categorie: parseFkId(json['categorie'] ?? json['id_categorie']),
      fournisseur: parseFkIdNullable(json['fournisseur'] ?? json['id_fournisseur']),
      image: (json['image'] ?? json['photo_base64'])?.toString(),
      dateCreation: json['date_creation'] != null
          ? DateTime.tryParse(json['date_creation'].toString())
          : null,
    );
  }

  /// Payload POST/PUT — clés attendues par `ProduitSerializer`.
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'code_barres': codeBarres,
      'nom': nom,
      'description': description,
      'prix_achat': prixAchat,
      'prix_vente': prixVente,
      'contenance': contenance,
      'stock_minimum': stockMinimum,
      'actif': actif,
      'categorie': categorie,
      if (fournisseur != null) 'fournisseur': fournisseur,
      if (image != null) 'image': image,
    };
  }

  Produit copyWith({
    int? idProduit,
    String? code,
    String? codeBarres,
    String? nom,
    String? description,
    double? prixAchat,
    double? prixVente,
    String? contenance,
    int? stockMinimum,
    bool? actif,
    int? categorie,
    int? fournisseur,
    String? image,
    DateTime? dateCreation,
    bool clearFournisseur = false,
    bool clearImage = false,
  }) {
    return Produit(
      idProduit: idProduit ?? this.idProduit,
      code: code ?? this.code,
      codeBarres: codeBarres ?? this.codeBarres,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      prixAchat: prixAchat ?? this.prixAchat,
      prixVente: prixVente ?? this.prixVente,
      contenance: contenance ?? this.contenance,
      stockMinimum: stockMinimum ?? this.stockMinimum,
      actif: actif ?? this.actif,
      categorie: categorie ?? this.categorie,
      fournisseur: clearFournisseur ? null : (fournisseur ?? this.fournisseur),
      image: clearImage ? null : (image ?? this.image),
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }
}
