import 'role.dart';

/// Modèle aligné sur `UtilisateurSerializer` (DRF).
/// Champs exposés par le backend : id, username, role, nom, prenom, email, etc.
class Utilisateur {
  final int id;
  final String username;
  final String nom;
  final String prenom;
  final String? telephone;
  final String email;
  final String statut;
  final Role? role;
  final String? photo;
  final DateTime? dateCreation;

  Utilisateur({
    required this.id,
    required this.username,
    required this.nom,
    required this.prenom,
    this.telephone,
    required this.email,
    required this.statut,
    this.role,
    this.photo,
    this.dateCreation,
  });

  int get roleId => role?.idRole ?? 0;

  String get nomRole => role?.nomRole ?? '';

  bool get isAdministrateur => nomRole == 'Administrateur' || roleId == 1;

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: _parseInt(json['id']),
      username: json['username'].toString(),
      nom: json['nom'].toString(),
      prenom: json['prenom'].toString(),
      telephone: json['telephone']?.toString(),
      email: json['email'].toString(),
      statut: json['statut'].toString(),
      role: json['role'] is Map<String, dynamic>
          ? Role.fromJson(json['role'] as Map<String, dynamic>)
          : null,
      photo: json['photo']?.toString(),
      dateCreation: json['date_creation'] != null
          ? DateTime.tryParse(json['date_creation'].toString())
          : null,
    );
  }

  /// Payload PUT/PATCH — `UtilisateurSerializer` (écriture via `role_id`).
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'email': email,
      'statut': statut,
      if (roleId > 0) 'role_id': roleId,
    };
  }

  /// Payload POST — `UtilisateurCreationSerializer` (`role` en FK, pas `role_id`).
  Map<String, dynamic> toCreateJson({required String password}) {
    return {
      'username': username,
      'password': password,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'email': email,
      'statut': statut,
      'role': roleId,
    };
  }

  Utilisateur copyWith({
    int? id,
    String? username,
    String? nom,
    String? prenom,
    String? telephone,
    String? email,
    String? statut,
    Role? role,
    String? photo,
    DateTime? dateCreation,
  }) {
    return Utilisateur(
      id: id ?? this.id,
      username: username ?? this.username,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      statut: statut ?? this.statut,
      role: role ?? this.role,
      photo: photo ?? this.photo,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.parse(value.toString());
  }
}
