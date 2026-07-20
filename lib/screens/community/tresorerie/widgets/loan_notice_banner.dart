import 'package:flutter/material.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Bandeau d'information (pas une alerte) rappelant qu'un prêt en cours
/// bloque une nouvelle demande.
class LoanNoticeBanner extends StatelessWidget {
  const LoanNoticeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.profileBannerBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.loanNoticeText, size: 18),
          SizedBox(width: AppDimensions.spaceSm.w),
          Expanded(
            child: Text(
              AppLocalizations.t('loan_notice'),
              style: const TextStyle(fontSize: 12, color: AppColors.loanNoticeText),
            ),
          ),
        ],
      ),
    );
  }
}