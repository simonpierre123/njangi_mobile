import 'package:flutter/material.dart';
import '../../../../Models/community_admin_dashboard_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "Statut des membres" — répartition total/à jour/en attente/en
/// retard + accès à la gestion des membres.
class MembersStatusCard extends StatelessWidget {
  const MembersStatusCard({super.key, required this.stats, required this.onManageMembers});

  final MemberStatusStats stats;
  final VoidCallback onManageMembers;

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
          Row(
            children: [
              _StatusBox(
                title: AppLocalizations.t('total_label'),
                count: '${stats.total}',
                bg: AppColors.white,
                textColor: AppColors.textPrimary,
                hasBorder: true,
              ),
              SizedBox(width: AppDimensions.spaceSm.w),
              _StatusBox(
                title: AppLocalizations.t('up_to_date'),
                count: '${stats.upToDate}',
                bg: AppColors.iconBgMint,
                textColor: AppColors.primaryDark,
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          Row(
            children: [
              _StatusBox(
                title: AppLocalizations.t('pending_label'),
                count: '${stats.pending}',
                bg: AppColors.warningBg,
                textColor: AppColors.warningText,
                labelMatchesValue: true,
              ),
              SizedBox(width: AppDimensions.spaceSm.w),
              _StatusBox(
                title: AppLocalizations.t('overdue_label'),
                count: '${stats.lateCount}',
                bg: AppColors.tagRedBg,
                textColor: AppColors.alertRed,
                labelMatchesValue: true,
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onManageMembers,
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
                    AppLocalizations.t('manage_members'),
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

class _StatusBox extends StatelessWidget {
  const _StatusBox({
    required this.title,
    required this.count,
    required this.bg,
    required this.textColor,
    this.hasBorder = false,
    this.labelMatchesValue = false,
  });

  final String title;
  final String count;
  final Color bg;
  final Color textColor;
  final bool hasBorder;
  final bool labelMatchesValue;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: hasBorder ? Border.all(color: AppColors.inputBorder) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: labelMatchesValue ? textColor : AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(count, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}