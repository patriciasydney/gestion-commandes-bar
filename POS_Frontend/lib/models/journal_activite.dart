// ============================================================================
// Modèle JournalActivite — reflète la table correspondante de schema.sql (PostgreSQL)
// Traduit le JSON renvoyé par l'API Django REST en objet Dart typé, et inversement.
// ============================================================================
class JournalActivite {
  final int idJournal;
  final int? idUtilisateur;
  final String action;
  final String? description;
  final DateTime dateAction;
  final String? adresseIp;

  JournalActivite({
    required this.idJournal,
    this.idUtilisateur,
    required this.action,
    this.description,
    required this.dateAction,
    this.adresseIp
  });

  /// Construit un JournalActivite à partir du JSON renvoyé par l'API.
  factory JournalActivite.fromJson(Map<String, dynamic> json) {
    return JournalActivite(
      idJournal: json['id_journal'] is int ? json['id_journal'] as int : int.parse(json['id_journal'].toString()),
      idUtilisateur: json['id_utilisateur'] is int ? json['id_utilisateur'] as int : int.tryParse(json['id_utilisateur'].toString()),
      action: json['action'].toString(),
      description: json['description']?.toString(),
      dateAction: DateTime.parse(json['date_action'].toString()),
      adresseIp: json['adresse_ip']?.toString()
    );
  }

  /// Transforme ce JournalActivite en JSON pour l'envoyer à l'API (POST/PUT).
  Map<String, dynamic> toJson() {
    return {
      'id_journal': idJournal,
      'id_utilisateur': idUtilisateur,
      'action': action,
      'description': description,
      'date_action': dateAction.toIso8601String(),
      'adresse_ip': adresseIp
    };
  }
}
