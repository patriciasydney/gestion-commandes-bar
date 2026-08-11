import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/utils/date_range.dart';
import '../core/utils/formatters.dart';
import '../models/dashboard_summary.dart';
import '../models/rapport.dart';
import '../services/dashboard_service.dart';
import '../services/rapport_service.dart';
import '../widgets/dashboard/sales_chart.dart';

/// État du tableau de bord — aligné sur `/dashboard/summary/` + rapports.
class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();
  final RapportService _rapportService = RapportService();

  bool chargement = false;
  bool chargementPeriode = false;
  bool chargementGraphique = false;
  String? erreur;

  DateTime? dateJour;
  List<ProduitStockFaible> stocksFaibles = [];

  /// Période active : `jour` | `7j` | `30j`
  String periodeActive = 'jour';
  ModeGraphiqueVentes modeGraphique = ModeGraphiqueVentes.barres;
  List<PointVenteGraphique> pointsGraphique = const [];

  double chiffreAffairesPeriode = 0;
  int nombreVentesPeriode = 0;
  double depensesPeriode = 0;
  double panierMoyenPeriode = 0;

  Timer? _autoRefresh;
  static const _intervalleRefresh = Duration(minutes: 3);

  String get libellePeriode => switch (periodeActive) {
        '7j' => '7 derniers jours',
        '30j' => '30 derniers jours',
        _ => "Aujourd'hui",
      };

  String get libelleCa => switch (periodeActive) {
        '7j' => 'CA (7 jours)',
        '30j' => 'CA (30 jours)',
        _ => "Chiffre d'affaires",
      };

  String get libelleVentes => switch (periodeActive) {
        '7j' => 'Ventes (7 j)',
        '30j' => 'Ventes (30 j)',
        _ => 'Ventes du jour',
      };

  String get libelleDepenses => switch (periodeActive) {
        '7j' => 'Dépenses (7 j)',
        '30j' => 'Dépenses (30 j)',
        _ => 'Dépenses du jour',
      };

  double get totalGraphique =>
      pointsGraphique.fold<double>(0, (s, p) => s + p.montant);

  double get moyenneGraphique => pointsGraphique.isEmpty
      ? 0
      : totalGraphique / pointsGraphique.length;

  PointVenteGraphique? get meilleurJourGraphique {
    if (pointsGraphique.isEmpty) return null;
    return pointsGraphique.reduce(
      (a, b) => a.montant >= b.montant ? a : b,
    );
  }

  Future<void> chargerDonnees({bool silencieux = false}) async {
    if (!silencieux) {
      chargement = true;
      erreur = null;
      notifyListeners();
    }

    try {
      final summary = await _dashboardService.getSummary();
      dateJour = summary.date;
      stocksFaibles = summary.produitsStockFaible;

      await Future.wait([
        _chargerKpisPeriode(silencieux: true),
        _chargerSerieGraphique(silencieux: true),
      ]);
    } catch (e) {
      if (!silencieux) erreur = e.toString();
    }

    if (!silencieux) chargement = false;
    notifyListeners();
  }

  void demarrerAutoRefresh() {
    _autoRefresh?.cancel();
    _autoRefresh = Timer.periodic(_intervalleRefresh, (_) {
      chargerDonnees(silencieux: true);
    });
  }

  void arreterAutoRefresh() {
    _autoRefresh?.cancel();
    _autoRefresh = null;
  }

  Future<void> changerPeriode(String periode) async {
    if (periode == periodeActive) return;
    periodeActive = periode;
    chargementPeriode = true;
    chargementGraphique = true;
    notifyListeners();
    try {
      await Future.wait([
        _chargerKpisPeriode(silencieux: true),
        _chargerSerieGraphique(silencieux: true),
      ]);
    } catch (e) {
      erreur = e.toString();
    } finally {
      chargementPeriode = false;
      chargementGraphique = false;
      notifyListeners();
    }
  }

  void changerModeGraphique(ModeGraphiqueVentes mode) {
    if (mode == modeGraphique) return;
    modeGraphique = mode;
    notifyListeners();
  }

  Future<String> exporterCsvGraphique() async {
    final lignes = <String>[
      'Évolution des ventes — $libellePeriode',
      'Généré le;${Formatters.dateHeure(DateTime.now())}',
      '',
      'Date;CA;Tickets',
      for (final p in pointsGraphique)
        '${Formatters.date(p.jour)};${p.montant.toStringAsFixed(0)};${p.tickets}',
      '',
      'Total;${totalGraphique.toStringAsFixed(0)}',
      'Moyenne/jour;${moyenneGraphique.toStringAsFixed(0)}',
    ];
    final csv = lignes.join('\n');
    await Clipboard.setData(ClipboardData(text: csv));
    return csv;
  }

  Future<void> _chargerKpisPeriode({bool silencieux = false}) async {
    final preset = _presetPour(periodeActive);
    final ventes = await _rapportService.getVentes(
      dateDebut: preset.debut,
      dateFin: preset.fin,
    );
    final depensesList = await _rapportService.getDepensesParCategorie(
      dateDebut: preset.debut,
      dateFin: preset.fin,
    );

    chiffreAffairesPeriode = ventes.totalVentes;
    nombreVentesPeriode = ventes.nombreVentes;
    panierMoyenPeriode =
        nombreVentesPeriode > 0 ? chiffreAffairesPeriode / nombreVentesPeriode : 0;
    depensesPeriode = depensesList.fold<double>(0, (s, d) => s + d.total);

    if (!silencieux) notifyListeners();
  }

  Future<void> _chargerSerieGraphique({bool silencieux = false}) async {
    final preset = _presetPour(periodeActive);
    final ventes = await _rapportService.getVentes(
      dateDebut: preset.debut,
      dateFin: preset.fin,
    );
    pointsGraphique = _pointsDepuisRapport(ventes, preset);
    if (!silencieux) notifyListeners();
  }

  PeriodePreset _presetPour(String periode) {
    return switch (periode) {
      '7j' => DateRange.septDerniersJours(),
      '30j' => DateRange.trenteDerniersJours(),
      _ => DateRange.depuisPreset('jour'),
    };
  }

  List<PointVenteGraphique> _pointsDepuisRapport(
    RapportVentes actuel,
    PeriodePreset preset,
  ) {
    final today = DateRange.dateOnly(DateTime.now());
    final jours = preset.fin.difference(preset.debut).inDays + 1;
    final stepLabel = jours <= 1
        ? 1
        : jours <= 7
            ? 1
            : jours <= 14
                ? 2
                : jours <= 31
                    ? 5
                    : 7;

    const lettres = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    double montantPour(DateTime day) {
      for (final d in actuel.detailParJour) {
        if (DateRange.sameDay(d.jour, day)) return d.totalJour;
      }
      return 0;
    }

    int ticketsPour(DateTime day) {
      for (final d in actuel.detailParJour) {
        if (DateRange.sameDay(d.jour, day)) return d.tickets;
      }
      return 0;
    }

    return List.generate(jours, (i) {
      final day = preset.debut.add(Duration(days: i));
      final estAujourdhui = DateRange.sameDay(day, today);
      final montrerLabel = i == 0 ||
          i == jours - 1 ||
          estAujourdhui ||
          i % stepLabel == 0;

      final label = !montrerLabel
          ? ''
          : jours <= 1
              ? Formatters.date(day)
              : jours <= 7
                  ? lettres[day.weekday - 1]
                  : '${day.day}/${day.month}';

      return PointVenteGraphique(
        jour: day,
        montant: montantPour(day),
        tickets: ticketsPour(day),
        label: label,
        estAujourdhui: estAujourdhui,
      );
    });
  }

  @override
  void dispose() {
    arreterAutoRefresh();
    super.dispose();
  }
}
