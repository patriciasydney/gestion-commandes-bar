/// Parse un champ FK renvoyé par DRF (int ou objet nested).
int parseFkId(dynamic value) {
  if (value is int) return value;
  if (value is Map<String, dynamic>) {
    for (final key in const [
      'id',
      'id_produit',
      'id_utilisateur',
      'id_categorie',
      'id_fournisseur',
      'id_vente',
      'id_client',
      'id_role',
    ]) {
      if (value[key] != null) return parseFkId(value[key]);
    }
  }
  return int.parse(value.toString());
}

int? parseFkIdNullable(dynamic value) {
  if (value == null) return null;
  return parseFkId(value);
}
