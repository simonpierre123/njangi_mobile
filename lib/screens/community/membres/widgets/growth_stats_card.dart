import 'package:flutter/material.dart';
import '../../../../Models/community_members_model.dart';
import '../../../../common/basewidget/percent_ring.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "Croissance mensuelle" — vue admin.
class GrowthStatsCard extends StatelessWidget {
  const GrowthStatsCard({super.key, required this.growth});

  final GrowthStats growth;

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.t('growth_title'),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                growth.newMembersLabel,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
              ),
            ],
          ),
          PercentRing(percent: growth.percent, size: 48, strokeWidth: 5, color: AppColors.primaryDark),
        ],
      ),
    );
  }
}