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

    return SizedBox(
      height: 220,
      width: double.infinity,
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
                  style: const TextStyle(fontSize: 11, color: AppColors.texteClair),
                ),
              ),
            ),
          ),
          barGroups: [
            for (int i = 0; i < ventesParJour.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: ventesParJour[i].toDouble(),
                  color: AppColors.bleuFonce,
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
