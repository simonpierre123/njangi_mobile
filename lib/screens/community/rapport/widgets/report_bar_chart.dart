import 'package:flutter/material.dart';
import '../../../../Models/report_model.dart';
import '../../../../utils/app_colors.dart';

/// Graphique en barres — "Évolution des versements". La barre la plus
/// haute (objectif atteint) est mise en évidence en vert foncé, les
/// autres restent en teinte claire.
class ReportBarChart extends StatelessWidget {
  const ReportBarChart({super.key, required this.points, this.height = 110});

  final List<ChartPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxValue = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final p in points) ...[
                Expanded(
                  child: FractionallySizedBox(
                    heightFactor: p.value.clamp(0.05, 1.0),
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: p.value == maxValue ? AppColors.primaryDark : AppColors.primaryDark10,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                  ),
                ),
                if (p != points.last) const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final p in points)
              Text(p.label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}