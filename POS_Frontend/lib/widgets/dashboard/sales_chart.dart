import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../common/chart_zoom.dart';

/// Point journalier pour le graphique d'évolution des ventes.
class PointVenteGraphique {
  const PointVenteGraphique({
    required this.jour,
    required this.montant,
    required this.label,
    this.tickets = 0,
    this.montantPrecedent = 0,
    this.estAujourdhui = false,
  });

  final DateTime jour;
  final double montant;
  final String label;
  final int tickets;
  final double montantPrecedent;
  final bool estAujourdhui;
}

enum ModeGraphiqueVentes { barres, courbe }

/// Graphique des ventes — barres/courbe, zoom horizontal, tooltips.
class SalesChart extends StatefulWidget {
  const SalesChart({
    super.key,
    required this.points,
    this.mode = ModeGraphiqueVentes.barres,
    this.afficherComparaison = true,
    this.hauteur = 260,
    this.afficherZoom = true,
    this.onJourSelectionne,
  });

  final List<PointVenteGraphique> points;
  final ModeGraphiqueVentes mode;
  final bool afficherComparaison;
  final double hauteur;
  final bool afficherZoom;

  /// Clic sur un jour → drill-down détail des ventes.
  final ValueChanged<PointVenteGraphique>? onJourSelectionne;

  @override
  State<SalesChart> createState() => _SalesChartState();
}

class _SalesChartState extends State<SalesChart> {
  double _zoom = ChartZoom.min;

  @override
  void didUpdateWidget(covariant SalesChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points.length != widget.points.length) {
      _zoom = ChartZoom.min;
    }
  }

  List<PointVenteGraphique> get points => widget.points;
  ModeGraphiqueVentes get mode => widget.mode;
  bool get afficherComparaison => widget.afficherComparaison;

  double get _maxY {
    if (points.isEmpty) return 100;
    var maxVal = 0.0;
    for (final p in points) {
      if (p.montant > maxVal) maxVal = p.montant;
      if (afficherComparaison && p.montantPrecedent > maxVal) {
        maxVal = p.montantPrecedent;
      }
    }
    if (maxVal <= 0) return 100;
    return maxVal * 1.18;
  }

  double get _largeurBarre {
    final n = points.length;
    final base = n <= 7
        ? (afficherComparaison ? 10.0 : 18.0)
        : n <= 14
            ? (afficherComparaison ? 7.0 : 12.0)
            : n <= 31
                ? (afficherComparaison ? 5.0 : 8.0)
                : 4.0;
    return (base * _zoom).clamp(4.0, 36.0);
  }

  double get _baseParPoint => afficherComparaison ? 28.0 : 24.0;

  bool get _zoomActif =>
      widget.afficherZoom && ChartZoom.usefulFor(points.length);

  String _formatAxe(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(v >= 10000 ? 0 : 1)}k';
    return v.toStringAsFixed(0);
  }

  String _labelBas(int i) {
    final p = points[i];
    if (p.label.isNotEmpty) return p.label;
    if (_zoom >= 2.5) return '${p.jour.day}/${p.jour.month}';
    if (_zoom >= 1.5) {
      final step = points.length > 20 ? 2 : 1;
      return i % step == 0 ? '${p.jour.day}/${p.jour.month}' : '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Container(
        height: widget.hauteur,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(
          'Aucune donnée sur cette période',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.texteClair,
              ),
        ),
      );
    }

    final chart = mode == ModeGraphiqueVentes.courbe
        ? _buildLineChart(context)
        : _buildBarChart(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_zoomActif) ...[
          Align(
            alignment: Alignment.centerRight,
            child: ChartZoomBar(
              zoom: _zoom,
              onChanged: (z) => setState(() => _zoom = z),
            ),
          ),
          const SizedBox(height: 8),
        ],
        ZoomableChartArea(
          height: widget.hauteur,
          pointCount: points.length,
          zoom: _zoom,
          basePerPoint: _baseParPoint,
          child: chart,
        ),
        if (afficherComparaison) ...[
          const SizedBox(height: 10),
          _LegendeComparaison(mode: mode),
        ],
        if (widget.onJourSelectionne != null) ...[
          const SizedBox(height: 8),
          Text(
            'Touchez un jour pour voir le détail des ventes',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.texteClair,
                ),
          ),
        ],
      ],
    );
  }

  void _notifierSelection(int index) {
    final cb = widget.onJourSelectionne;
    if (cb == null || index < 0 || index >= points.length) return;
    cb(points[index]);
  }

  Widget _buildBarChart(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    final couleurNormale = sombre ? AppColors.orangeClair : AppColors.bleuFonce;
    final couleurJour = AppColors.orange;
    final couleurPrec = sombre
        ? AppColors.texteClairSombre.withValues(alpha: 0.45)
        : AppColors.texteClair.withValues(alpha: 0.55);
    final textStyle = Theme.of(context).textTheme.labelSmall;

    return BarChart(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      BarChartData(
        maxY: _maxY,
        alignment: BarChartAlignment.spaceAround,
        groupsSpace: afficherComparaison ? 6 : 10,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchCallback: (event, response) {
            if (event is! FlTapUpEvent) return;
            final spot = response?.spot;
            if (spot == null) return;
            _notifierSelection(spot.touchedBarGroupIndex);
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) =>
                sombre ? AppColors.surfaceAltSombre : AppColors.bleuFonce,
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex < 0 || groupIndex >= points.length) return null;
              final p = points[groupIndex];
              final estPrec = afficherComparaison && rodIndex == 0;
              final montant = estPrec ? p.montantPrecedent : p.montant;
              final lignes = <String>[
                Formatters.date(p.jour),
                if (estPrec) 'Période préc. : ${Formatters.montant(montant)}',
                if (!estPrec) ...[
                  Formatters.montant(montant),
                  if (afficherComparaison)
                    'Préc. : ${Formatters.montant(p.montantPrecedent)}',
                  if (p.tickets > 0)
                    '${p.tickets} ticket${p.tickets > 1 ? 's' : ''}',
                ],
              ];
              return BarTooltipItem(
                lignes.join('\n'),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.35,
                ),
              );
            },
          ),
        ),
        titlesData: _titlesData(context, textStyle),
        barGroups: [
          for (int i = 0; i < points.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 2,
              barRods: [
                if (afficherComparaison)
                  BarChartRodData(
                    toY: points[i].montantPrecedent,
                    color: couleurPrec,
                    width: _largeurBarre,
                    borderRadius: BorderRadius.circular(3),
                  ),
                BarChartRodData(
                  toY: points[i].montant,
                  color: points[i].estAujourdhui ? couleurJour : couleurNormale,
                  width: _largeurBarre,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    final couleur = sombre ? AppColors.orangeClair : AppColors.bleuFonce;
    final couleurPrec = sombre
        ? AppColors.texteClairSombre.withValues(alpha: 0.5)
        : AppColors.texteClair;
    final textStyle = Theme.of(context).textTheme.labelSmall;
    final montrerPoints = points.length <= 14 || _zoom >= 1.5;

    return LineChart(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: _maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchCallback: (event, response) {
            if (event is! FlTapUpEvent) return;
            final spots = response?.lineBarSpots;
            if (spots == null || spots.isEmpty) return;
            _notifierSelection(spots.first.x.toInt());
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) =>
                sombre ? AppColors.surfaceAltSombre : AppColors.bleuFonce,
            getTooltipItems: (touched) {
              return touched.map((t) {
                final i = t.x.toInt();
                if (i < 0 || i >= points.length) return null;
                final p = points[i];
                final estPrec = afficherComparaison && t.barIndex == 0;
                final montant = estPrec ? p.montantPrecedent : p.montant;
                return LineTooltipItem(
                  [
                    Formatters.date(p.jour),
                    if (estPrec)
                      'Préc. : ${Formatters.montant(montant)}'
                    else ...[
                      Formatters.montant(montant),
                      if (afficherComparaison)
                        'Préc. : ${Formatters.montant(p.montantPrecedent)}',
                      if (p.tickets > 0)
                        '${p.tickets} ticket${p.tickets > 1 ? 's' : ''}',
                    ],
                  ].join('\n'),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.35,
                  ),
                );
              }).toList();
            },
          ),
        ),
        titlesData: _titlesData(context, textStyle),
        lineBarsData: [
          if (afficherComparaison)
            LineChartBarData(
              spots: [
                for (int i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i].montantPrecedent),
              ],
              isCurved: true,
              color: couleurPrec,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              dashArray: [6, 4],
            ),
          LineChartBarData(
            spots: [
              for (int i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].montant),
            ],
            isCurved: true,
            color: couleur,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: montrerPoints,
              getDotPainter: (spot, percent, bar, index) {
                final auj = index < points.length && points[index].estAujourdhui;
                return FlDotCirclePainter(
                  radius: auj ? 5 : 3,
                  color: auj ? AppColors.orange : couleur,
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: couleur.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  FlTitlesData _titlesData(BuildContext context, TextStyle? textStyle) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          interval: _maxY / 4,
          getTitlesWidget: (value, meta) {
            if (value <= 0 || value >= _maxY) {
              return const SizedBox.shrink();
            }
            return Text(
              _formatAxe(value),
              style: textStyle?.copyWith(fontSize: 10),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (value, meta) {
            final i = value.toInt();
            if (i < 0 || i >= points.length) {
              return const SizedBox.shrink();
            }
            if ((value - i).abs() > 0.01) {
              return const SizedBox.shrink();
            }
            final label = _labelBas(i);
            if (label.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                label,
                style: textStyle?.copyWith(
                  fontWeight: points[i].estAujourdhui
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: points[i].estAujourdhui ? AppColors.orange : null,
                  fontSize: points.length > 14 && _zoom < 2 ? 9 : 11,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LegendeComparaison extends StatelessWidget {
  const _LegendeComparaison({required this.mode});

  final ModeGraphiqueVentes mode;

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    final actuelle = sombre ? AppColors.orangeClair : AppColors.bleuFonce;
    final prec = AppColors.texteClair;

    return Row(
      children: [
        _puce(actuelle, mode == ModeGraphiqueVentes.courbe),
        const SizedBox(width: 6),
        Text('Période actuelle', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(width: 16),
        _puce(prec, mode == ModeGraphiqueVentes.courbe, dashed: true),
        const SizedBox(width: 6),
        Text('Période préc.', style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }

  Widget _puce(Color color, bool ligne, {bool dashed = false}) {
    if (ligne) {
      return CustomPaint(
        size: const Size(18, 3),
        painter: _LigneLegendePainter(color: color, dashed: dashed),
      );
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color.withValues(alpha: dashed ? 0.5 : 1),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _LigneLegendePainter extends CustomPainter {
  _LigneLegendePainter({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    if (!dashed) {
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
      return;
    }
    const dash = 3.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset((x + dash).clamp(0, size.width), size.height / 2),
        paint,
      );
      x += dash * 2;
    }
  }

  @override
  bool shouldRepaint(covariant _LigneLegendePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dashed != dashed;
}

/// Bandeau résumé sous le graphique.
class ResumeGraphiqueVentes extends StatelessWidget {
  const ResumeGraphiqueVentes({
    super.key,
    required this.total,
    required this.moyenne,
    required this.meilleurMontant,
    required this.meilleurJour,
    this.variationPct,
  });

  final double total;
  final double moyenne;
  final double meilleurMontant;
  final DateTime? meilleurJour;
  final double? variationPct;

  @override
  Widget build(BuildContext context) {
    final variation = variationPct;
    final couleurVar = variation == null
        ? AppColors.texteClair
        : variation >= 0
            ? AppColors.vert
            : AppColors.rouge;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 640 ? 4 : 2;
        final w = (constraints.maxWidth - (cols - 1) * 10) / cols;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: w,
              child: _CarteResume(
                titre: 'Total période',
                valeur: Formatters.montant(total),
                icone: Icons.payments_outlined,
              ),
            ),
            SizedBox(
              width: w,
              child: _CarteResume(
                titre: 'Moyenne / jour',
                valeur: Formatters.montant(moyenne),
                icone: Icons.trending_up,
              ),
            ),
            SizedBox(
              width: w,
              child: _CarteResume(
                titre: 'Meilleur jour',
                valeur: Formatters.montant(meilleurMontant),
                sousTitre: meilleurJour != null
                    ? Formatters.date(meilleurJour!)
                    : null,
                icone: Icons.emoji_events_outlined,
              ),
            ),
            SizedBox(
              width: w,
              child: _CarteResume(
                titre: 'vs période préc.',
                valeur: variation == null
                    ? '—'
                    : '${variation >= 0 ? '+' : ''}${variation.toStringAsFixed(1)} %',
                icone: variation != null && variation >= 0
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                couleurValeur: couleurVar,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CarteResume extends StatelessWidget {
  const _CarteResume({
    required this.titre,
    required this.valeur,
    required this.icone,
    this.sousTitre,
    this.couleurValeur,
  });

  final String titre;
  final String valeur;
  final IconData icone;
  final String? sousTitre;
  final Color? couleurValeur;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(icone, size: 18, color: AppColors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.texteClair,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  valeur,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: couleurValeur,
                      ),
                ),
                if (sousTitre != null)
                  Text(
                    sousTitre!,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
