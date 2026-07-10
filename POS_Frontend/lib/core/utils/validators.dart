/// Validateurs réutilisables pour les formulaires (Form + TextFormField).
class Validators {
  Validators._();

  static String? requis(String? valeur, {String champ = "Ce champ"}) {
    if (valeur == null || valeur.trim().isEmpty) {
      return "$champ est requis";
    }
    return null;
  }

  static String? email(String? valeur) {
    if (valeur == null || valeur.trim().isEmpty) return "L'email est requis";
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(valeur)) return "Email invalide";
    return null;
  }

  static String? motDePasse(String? valeur) {
    if (valeur == null || valeur.isEmpty) return "Le mot de passe est requis";
    if (valeur.length < 6) return "6 caractères minimum";
    return null;
  }

  static String? nombrePositif(String? valeur, {String champ = "La valeur"}) {
    if (valeur == null || valeur.trim().isEmpty) return "$champ est requis";
    final n = num.tryParse(valeur);
    if (n == null) return "$champ doit être un nombre";
    if (n < 0) return "$champ doit être positif";
    return null;
  }
}
