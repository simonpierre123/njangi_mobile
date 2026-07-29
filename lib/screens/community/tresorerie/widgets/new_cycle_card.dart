import 'package:flutter/material.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte de clôture "Prêt pour un nouveau cycle" — fond vert foncé,
/// bouton principal blanc, lien secondaire.
class NewCycleCard extends StatelessWidget {
  const NewCycleCard({super.key, required this.onStartNewCycle, required this.onSeeCyclesHistory});

  final VoidCallback onStartNewCycle;
  final VoidCallback onSeeCyclesHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceLg.w),
      decoration: BoxDecoration(
        color: AppColors.primaryDeep,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.t('ready_new_cycle_title'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white),
          ),
          SizedBox(height: AppDimensions.spaceXs.h),
          Text(
            AppLocalizations.t('ready_new_cycle_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.cycleBadgeBg.withValues(alpha: 0.80)),
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Material(
            color: AppColors.cycleBadgeBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            child: InkWell(
              onTap: onStartNewCycle,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.t('start_new_cycle_button'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                ),
              ),
            ),
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          GestureDetector(
            onTap: onSeeCyclesHistory,
            child: Text(
              AppLocalizations.t('see_cycles_history_link'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.cycleBadgeBg),
            ),
          ),
        ],
      ),
    );
  }
}