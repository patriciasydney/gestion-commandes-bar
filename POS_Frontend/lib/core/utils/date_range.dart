import 'package:intl/intl.dart' as intl;

import 'formatters.dart';

/// Plage de dates pour les rapports (presets jour / semaine / mois / année).
class PeriodePreset {
  final DateTime debut;
  final DateTime fin;
  final String libelle;

  const PeriodePreset({
    required this.debut,
    required this.fin,
    required this.libelle,
  });
}

class DateRange {
  DateRange._();

  static String toApiDate(DateTime date) {
    return intl.DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Calcule la plage selon le preset UI (`jour`, `semaine`, `mois`, `annee`).
  static PeriodePreset depuisPreset(String periode) {
    final today = dateOnly(DateTime.now());

    switch (periode) {
      case 'semaine':
        final lundi = today.subtract(Duration(days: today.weekday - DateTime.monday));
        return PeriodePreset(
          debut: lundi,
          fin: today,
          libelle: 'Semaine du ${Formatters.date(lundi)} au ${Formatters.date(today)}',
        );
      case 'mois':
        final debutMois = DateTime(today.year, today.month, 1);
        return PeriodePreset(
          debut: debutMois,
          fin: today,
          libelle: 'Ce mois-ci (${Formatters.date(debutMois)} – ${Formatters.date(today)})',
        );
      case 'annee':
        final debutAnnee = DateTime(today.year, 1, 1);
        return PeriodePreset(
          debut: debutAnnee,
          fin: today,
          libelle: 'Cette année (${today.year})',
        );
      case 'jour':
      default:
        return PeriodePreset(
          debut: today,
          fin: today,
          libelle: "Aujourd'hui — ${Formatters.date(today)}",
        );
    }
  }

  /// 7 derniers jours calendaires (J-6 … aujourd'hui).
  static PeriodePreset septDerniersJours() {
    final today = dateOnly(DateTime.now());
    final debut = today.subtract(const Duration(days: 6));
    return PeriodePreset(
      debut: debut,
      fin: today,
      libelle: '7 derniers jours',
    );
  }

  static String queryParams({DateTime? dateDebut, DateTime? dateFin}) {
    final params = <String, String>{};
    if (dateDebut != null) params['date_debut'] = toApiDate(dateDebut);
    if (dateFin != null) params['date_fin'] = toApiDate(dateFin);
    if (params.isEmpty) return '';
    return '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
  }
}
