import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// Anneau de progression circulaire avec le pourcentage centré.
/// Réutilisé pour le score de confiance et la croissance mensuelle
/// (onglet Membres), et potentiellement ailleurs.
class PercentRing extends StatelessWidget {
  const PercentRing({
    super.key,
    required this.percent,
    this.size = 56,
    this.strokeWidth = 5,
    this.color = AppColors.primaryDark,
    this.backgroundColor,
  });

  final double percent; // 0.0 à 1.0
  final double size;
  final double strokeWidth;
  final Color color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percent,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor ?? AppColors.neutralGrayLighter,
              color: color,
            ),
          ),
          Text(
            '${(percent * 100).round()}%',
            style: TextStyle(fontSize: size * 0.26, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}