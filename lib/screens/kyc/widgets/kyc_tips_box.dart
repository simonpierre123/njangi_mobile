import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Bloc "Conseils pour réussir" (KYC3) — fond vert clair, icône
/// d'en-tête, lignes de texte simples (pas de coche, contrairement à
/// KycChecklistBox).
class KycTipsBox extends StatelessWidget {
  const KycTipsBox({super.key, required this.tips});

  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.profileBannerBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.stepGreen),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.t('kyc_tips_section'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.stepGreen),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(tip, style: const TextStyle(fontSize: 12, color: AppColors.stepGreen)),
            ),
        ],
      ),
    );
  }
}