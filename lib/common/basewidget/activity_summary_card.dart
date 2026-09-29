import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import 'stat_chip.dart';

enum ActivitySummaryVariant { empty, filled }

/// Carte de synthèse d'activité sur le tableau de bord — deux variantes :
/// vide (aucune communauté, fond blanc contouré) ou remplie (fond vert
/// [AppColors.mediumGreen] + pattern décoratif en arrière-plan). Le caller
/// doit passer des [StatChip] déjà configurés avec le bon [StatChipTone].
class ActivitySummaryCard extends StatelessWidget {
  const ActivitySummaryCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.chips,
    required this.pendingAmountLabel,
    required this.pendingAmount,
    this.variant = ActivitySummaryVariant.empty,
    this.hasAlert = false,
  });

  final String eyebrow;
  final String title;
  final List<StatChip> chips;
  final String pendingAmountLabel;
  final String pendingAmount;
  final ActivitySummaryVariant variant;
  final bool hasAlert;

  @override
  Widget build(BuildContext context) {
    final isFilled = variant == ActivitySummaryVariant.filled;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.mediumGreen : AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: isFilled ? null : Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (isFilled)
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  'assets/images/subtle_pattern.png',
                  fit: BoxFit.cover,
               
                  // Le pattern est décoratif : si l'asset n'est pas encore
                  // déposé, on ne casse pas l'écran.
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(AppDimensions.spaceLg.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isFilled ? AppColors.white70 : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppDimensions.spaceXs.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isFilled ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                    if (hasAlert) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.badgeRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: AppDimensions.spaceMd.h),
                Wrap(spacing: 8, runSpacing: 8, children: chips),
                SizedBox(height: AppDimensions.spaceLg.h),
                Divider(
                  height: 1,
                  color: isFilled ? AppColors.white.withValues(alpha: 0.2) : AppColors.divider,
                ),
                SizedBox(height: AppDimensions.spaceMd.h),
                
                SizedBox(height: AppDimensions.spaceSm.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pendingAmountLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: isFilled ? AppColors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      pendingAmount,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isFilled ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}