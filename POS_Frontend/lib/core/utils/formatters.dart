import 'package:intl/intl.dart' as intl;

/// Fonctions de formatage réutilisées dans toute l'application.
class Formatters {
  Formatters._();

  /// Formate un montant en FCFA, ex : 1500 -> "1 500 FCFA"
  static String montant(num valeur) {
    final formatter = intl.NumberFormat('#,##0', 'fr_FR');
    return "${formatter.format(valeur)} FCFA";
  }

  /// Formate une date, ex : 2026-07-07 -> "07/07/2026"
  static String date(DateTime date) {
    return intl.DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formate une date + heure, ex : "07/07/2026 14:30"
  static String dateHeure(DateTime date) {
    return intl.DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Formate une durée écoulée depuis [date], ex : "il y a 12 min"
  static String tempsRelatif(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "à l'instant";
    if (diff.inMinutes < 60) return "il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "il y a ${diff.inHours} h";
    return "il y a ${diff.inDays} j";
  }
}
