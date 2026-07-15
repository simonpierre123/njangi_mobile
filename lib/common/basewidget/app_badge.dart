import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';

enum AppBadgeVariant { outline, filled }

/// Petit badge/chip réutilisable (ex: "Communauté", "Bienvenue sur...").
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = AppBadgeVariant.outline,
  });

  final String label;
  final IconData? icon;
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final isFilled = variant == AppBadgeVariant.filled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFilled ? AppColors.mintSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: isFilled ? null : Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.primaryDark),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: isFilled ? 0.5 : 0,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}