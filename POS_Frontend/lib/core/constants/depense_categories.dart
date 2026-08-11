/// Catégories de dépenses — alignées sur `apps.depenses.constants`.
class DepenseCategories {
  DepenseCategories._();

  static const String toutes = 'Toutes';

  static const List<String> saisie = [
    'Charges fixes',
    'Carburant',
    'Fournitures',
    'Salaires',
    'Maintenance',
    'Marketing',
    'Autre',
  ];

  static const List<String> filtres = [
    toutes,
    ...saisie,
  ];

  /// Anciennes valeurs techniques en base (seed historique).
  static const Map<String, String> _legacy = {
    'electricite': 'Charges fixes',
    'eau': 'Charges fixes',
    'transport': 'Carburant',
  };

  /// Retourne le libellé affiché / utilisé pour les filtres.
  static String normaliser(String categorie) {
    final trimmed = categorie.trim();
    if (trimmed.isEmpty) return 'Autre';
    return _legacy[trimmed.toLowerCase()] ?? trimmed;
  }

  static bool correspondFiltre(String categorieDepense, String filtre) {
    if (filtre == toutes) return true;
    return normaliser(categorieDepense) == filtre;
  }
}
