import 'package:flutter/material.dart';
import '../../../../ModeView/community_members_model.dart';
import '../../../../common/basewidget/percent_ring.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "Score de Confiance du Groupe" — vue non-admin.
class TrustScoreCard extends StatelessWidget {
  const TrustScoreCard({super.key, required this.score});

  final TrustScore score;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.mintSurfaceLighter,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      child: Row(
        children: [
          if (score.isAvailable)
            PercentRing(
              percent: score.percent,
              size: 48,
              strokeWidth: 5,
              color: AppColors.primaryDark,
            )
          else
            const Icon(
              Icons.bar_chart_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
          SizedBox(width: AppDimensions.spaceMd.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.t('trust_score_title'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  score.summary,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
