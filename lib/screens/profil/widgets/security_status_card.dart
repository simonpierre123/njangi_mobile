import 'package:flutter/material.dart';
import '../../../Models/profile_model.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Carte verte "Sécurité du compte" — niveau global + checklist.
class SecurityStatusCard extends StatelessWidget {
  const SecurityStatusCard({super.key, required this.status});

  final SecurityStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceLg.w),
      decoration: BoxDecoration(color: AppColors.mediumGreen, borderRadius: BorderRadius.circular(AppDimensions.radiusXl)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.t('account_security_eyebrow').toUpperCase(),
                style: TextStyle(color: AppColors.white70, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ),
              const Icon(Icons.verified_user_outlined, color: AppColors.white, size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Text(status.levelLabel, style: const TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          SizedBox(height: AppDimensions.spaceMd.h),
          for (final item in status.checklist)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 14, color: AppColors.white),
                  const SizedBox(width: 6),
                  Expanded(child: Text(item, style: const TextStyle(color: AppColors.white, fontSize: 12))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}