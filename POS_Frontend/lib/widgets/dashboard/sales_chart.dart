import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';

/// Graphique des ventes (barres).
class SalesChart extends StatelessWidget {
  final List<num> ventesParJour;
  final List<String>? labels;

  const SalesChart({
    super.key,
    this.ventesParJour = const [0, 0, 0, 0, 0, 0, 0],
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final jours = labels ?? const ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final couleurBarres = Theme.of(context).brightness == Brightness.dark
        ? AppColors.orangeClair
        : AppColors.bleuFonce;

    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  jours[value.toInt() % jours.length],
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ),
          barGroups: [
            for (int i = 0; i < ventesParJour.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: ventesParJour[i].toDouble(),
                  color: couleurBarres,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ]),
          ],
        ),
      ),
    );
  }
}