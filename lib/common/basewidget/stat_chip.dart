import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';

enum StatChipTone { light, dark }

/// Petite pastille statistique (ex: "3 Communautés", "Réunion demain").
class StatChip extends StatelessWidget {
  const StatChip({
    super.key,
    required this.label,
    this.icon,
    this.count,
    this.tone = StatChipTone.light,
  });

  final String label;
  final IconData? icon;
  final int? count;
  final StatChipTone tone;

  @override
  Widget build(BuildContext context) {
    final isDark = tone == StatChipTone.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.white15 : AppColors.mintSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: isDark ? AppColors.white : AppColors.primaryDark),
            const SizedBox(width: 4),
          ],
          if (count != null) ...[
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}