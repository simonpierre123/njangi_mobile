import 'package:flutter/material.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Bandeau d'information "Confiance et Sécurité" — titre + description,
/// contrairement à InfoBanner (common) qui n'affiche qu'un message
/// simple sur une ligne.
class TrustSecurityBanner extends StatelessWidget {
  const TrustSecurityBanner({super.key});

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
          const Icon(Icons.info_outline, size: 18, color: AppColors.stepGreen),
          SizedBox(width: AppDimensions.spaceSm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.t('trust_security_title'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.stepGreen),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.t('trust_security_desc'),
                  style: const TextStyle(fontSize: 11, color: AppColors.stepGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}