import 'package:flutter/material.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte affichée quand le membre n'a aucun prêt en cours.
class NoActiveLoanCard extends StatelessWidget {
  const NoActiveLoanCard({super.key});

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
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(color: AppColors.tagMintBg, shape: BoxShape.circle),
            child: const Icon(Icons.credit_card_outlined, color: AppColors.primaryDark, size: 26),
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Text(
            AppLocalizations.t('no_active_loan_title'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          Text(
            AppLocalizations.t('no_active_loan_subtitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
            child: Text(
              AppLocalizations.t('eligible_badge'),
              style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          Text(
            AppLocalizations.t('loan_request_note'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}