import 'package:flutter/material.dart';
import '../../../../Models/community_admin_dashboard_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "Activité récente" — dernières actions sur la communauté.
class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key, required this.items, required this.onSeeAll});

  final List<ActivityItem> items;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          for (final item in items) ...[
            _ActivityRow(item: item),
            SizedBox(height: AppDimensions.spaceSm.h),
          ],
          SizedBox(height: AppDimensions.spaceSm.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSeeAll,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.borderMint),
                backgroundColor: AppColors.iconBgMint,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.t('see_full_history'),
                    style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 16, color: AppColors.primaryDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 18, backgroundColor: item.iconBg, child: Icon(item.icon, color: item.iconColor, size: 18)),
        SizedBox(width: AppDimensions.spaceSm.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 2),
              Text(item.subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}