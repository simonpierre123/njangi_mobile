import 'package:flutter/material.dart';
import '../../../../Models/community_members_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Ligne de l'annuaire des membres — vue non-admin. Badge de statut
/// ("À jour" / "En retard") aligné à droite.
class MemberDirectoryRow extends StatelessWidget {
  const MemberDirectoryRow({super.key, required this.entry});

  final MemberDirectoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final isLate = entry.status == MemberRowStatus.late;
    final badgeBg = isLate ? AppColors.tagRedBg : AppColors.tagMintBg;
    final badgeText = isLate ? AppColors.alertRed : AppColors.primaryDark;
    final badgeLabel = isLate ? AppLocalizations.t('overdue_label') : AppLocalizations.t('up_to_date');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceMd.w, vertical: AppDimensions.spaceSm.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 20, backgroundColor: AppColors.neutralGrayLight),
          SizedBox(width: AppDimensions.spaceSm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                      ),
                    ),
                    if (entry.role != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        entry.role!,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.roleText),
                      ),
                    ],
                    if (entry.isHighlighted) ...[
                      const SizedBox(width: 4),
                      const Text('⭐', style: TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(entry.memberSinceLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          SizedBox(width: AppDimensions.spaceSm.w),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(AppDimensions.radiusXl)),
            child: Text(badgeLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeText)),
          ),
        ],
      ),
    );
  }
}