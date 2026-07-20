import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Bandeau incitant à compléter le profil, affiché tant que le profil
/// n'est pas complet ET que l'utilisateur ne l'a pas fermé via la croix.
class ProfileIncompleteBanner extends StatelessWidget {
  const ProfileIncompleteBanner({
    super.key,
    required this.onIdentify,
    required this.onDismiss,
  });

  final VoidCallback onIdentify;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spaceMd.w,
        AppDimensions.spaceMd.h,
        AppDimensions.spaceSm.w,
        AppDimensions.spaceMd.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.profileBannerBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.person_outline, color: AppColors.primaryDark, size: 18),
              SizedBox(width: AppDimensions.spaceSm.w),
              Expanded(
                child: Text(
                  AppLocalizations.t('profile_incomplete_banner'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              InkWell(
                onTap: onDismiss,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onIdentify,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.loanNoticeText,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              child: Text(
                AppLocalizations.t('identify_button'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}