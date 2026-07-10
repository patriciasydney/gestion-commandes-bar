/// URL de base de l'API Django REST Framework.
/// À adapter une fois le backend déployé (ex: https://sport.services-ztf.com/api).
class ApiConstants {
  ApiConstants._();

  /// true tant que le backend Django n'est pas branché : toutes les
  /// requêtes passent par MockApi au lieu d'un vrai appel HTTP.
  /// À repasser à false une fois le backend réel disponible.
  static const bool modeDemo = false;

  static const String baseUrl = "http://localhost:8000/api";

  // Endpoints — à ajuster une fois les routes Django connues.
  static const String login = "/auth/login/";
  static const String produits = "/produits/";
  static const String categories = "/categories/";
  static const String fournisseurs = "/fournisseurs/";
  static const String clients = "/clients/";
  static const String stocks = "/stocks/";
  static const String mouvementsStock = "/mouvements-stock/";
  static const String ventes = "/ventes/";
  static const String paiements = "/paiements/";
  static const String achats = "/achats/";
  static const String depenses = "/depenses/";
  static const String caisses = "/caisses/";
  static const String utilisateurs = "/utilisateurs/";
  static const String roles = "/roles/";
  static const String dashboard = "/dashboard/summary/";
  static const String reportsVentes = "/reports/ventes/";
  static const String reportsProduits = "/reports/produits/";
  static const String reportsDepenses = "/reports/depenses/";
  static const String reportsAchats = "/reports/achats/";
}
