import 'package:flutter/material.dart';
import '../../../../Models/report_model.dart';
import '../../../../utils/app_colors.dart';

/// Graphique en courbe avec zone remplie sous la ligne — "Évolution des
/// contributions".
class ContributionEvolutionChart extends StatelessWidget {
  const ContributionEvolutionChart({super.key, required this.points, this.height = 120});

  final List<ChartPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _LineChartPainter(points: points)),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final p in points)
              Text(p.label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.points});

  final List<ChartPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final dx = size.width / (points.length - 1);
    Offset offsetFor(int i) => Offset(dx * i, size.height * (1 - points[i].value));

    final line = Path()..moveTo(offsetFor(0).dx, offsetFor(0).dy);
    for (var i = 1; i < points.length; i++) {
      line.lineTo(offsetFor(i).dx, offsetFor(i).dy);
    }

    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()..color = AppColors.mintPale.withValues(alpha: 0.5),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.primaryDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => oldDelegate.points != points;
}