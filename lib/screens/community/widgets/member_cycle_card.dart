import 'package:flutter/material.dart';
import '../../../../Models/community_member_dashboard_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "Cycle en cours" côté membre — vue simplifiée avec un gros
/// pourcentage plutôt que le badge "Cycle X sur Y" de la vue admin.
class MemberCycleCard extends StatelessWidget {
  const MemberCycleCard({super.key, required this.info});

  final MemberCycleInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceLg.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.t('current_cycle'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(info.progressPercent * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 36, color: AppColors.primaryDark),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(info.progressLabel, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: info.progressPercent,
              backgroundColor: AppColors.neutralPill,
              color: AppColors.primaryDark,
              minHeight: 8,
            ),
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                '${AppLocalizations.t('next_beneficiary_colon')} ',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                info.nextBeneficiary,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${info.remainingCycles} ${AppLocalizations.t('cycles_remaining_period')}',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}