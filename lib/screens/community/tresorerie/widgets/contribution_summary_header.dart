import 'package:flutter/material.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// En-tête de la page "Contribution" — avatar, badge de statut, nom,
/// montant, période.
class ContributionSummaryHeader extends StatelessWidget {
  const ContributionSummaryHeader({
    super.key,
    required this.memberName,
    required this.amount,
    required this.periodLabel,
  });

  final String memberName;
  final String amount;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceLg.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.neutralGrayLighter,
                child: Icon(Icons.person, size: 34, color: AppColors.neutralGray),
              ),
              Positioned(
                top: -4,
                right: -16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.tagMintBg, borderRadius: BorderRadius.circular(AppDimensions.radiusXl)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, size: 12, color: AppColors.primaryDark),
                      const SizedBox(width: 3),
                      Text(
                        AppLocalizations.t('status_paid'),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          Text(memberName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          SizedBox(height: AppDimensions.spaceXs.h),
          Text(amount, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.secondaryGreen)),
          const SizedBox(height: 2),
          Text(periodLabel, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}