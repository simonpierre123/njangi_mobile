import 'package:flutter/material.dart';
import '../../../../Models/treasury_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte individuelle de contribution d'un membre (avatar, nom, montant,
/// statut) — même style de mini card bordée que
/// ContributionHistoryList, pour une cohérence visuelle entre les deux
/// onglets de la Trésorerie.
class MemberContributionRow extends StatelessWidget {
  const MemberContributionRow({super.key, required this.contribution});

  final MemberContribution contribution;

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(contribution.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.inputBorder),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd.w,
        vertical: AppDimensions.spaceSm.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 18, backgroundColor: AppColors.neutralGrayLight),
          SizedBox(width: AppDimensions.spaceSm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      contribution.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                    ),
                    Text(
                      contribution.amount,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(contribution.dateLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: colors.$1, borderRadius: BorderRadius.circular(AppDimensions.radiusSm)),
                      child: Text(
                        _statusLabel(contribution.status),
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: colors.$2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _statusColors(ContributionStatus status) {
    switch (status) {
      case ContributionStatus.upToDate:
        return (AppColors.tagMintBg, AppColors.primaryDark);
      case ContributionStatus.pending:
        return (AppColors.warningBg, AppColors.warningText);
      case ContributionStatus.late:
        return (AppColors.tagRedBg, AppColors.alertRed);
    }
  }

  String _statusLabel(ContributionStatus status) {
    switch (status) {
      case ContributionStatus.upToDate:
        return AppLocalizations.t('up_to_date');
      case ContributionStatus.pending:
        return AppLocalizations.t('pending_label');
      case ContributionStatus.late:
        return AppLocalizations.t('overdue_label');
    }
  }
}