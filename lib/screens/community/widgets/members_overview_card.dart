import 'package:flutter/material.dart';
import '../../../../Models/community_admin_dashboard_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "Membres" côté vue membre — lignes colorées pleine largeur
/// (À jour / En attente / En retard), différent de la grille 2x2 de la
/// vue admin (MembersStatusCard).
class MembersOverviewCard extends StatelessWidget {
  const MembersOverviewCard({super.key, required this.stats, required this.onSeeAllMembers});

  final MemberStatusStats stats;
  final VoidCallback onSeeAllMembers;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.t('members_title'),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textPrimary),
              ),
              Text(
                '${stats.total}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          _MemberRow(
            label: AppLocalizations.t('up_to_date'),
            count: stats.upToDate,
            bg: AppColors.tagMintBg,
            color: AppColors.primaryDark,
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          _MemberRow(
            label: AppLocalizations.t('pending_label'),
            count: stats.pending,
            bg: AppColors.warningBg,
            color: AppColors.warningText,
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          _MemberRow(
            label: AppLocalizations.t('overdue_label'),
            count: stats.lateCount,
            bg: AppColors.tagRedBg,
            color: AppColors.alertRed,
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSeeAllMembers,
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
                    AppLocalizations.t('see_all_members'),
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

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.label, required this.count, required this.bg, required this.color});

  final String label;
  final int count;
  final Color bg;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
          Text('$count', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}