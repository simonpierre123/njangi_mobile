import 'package:flutter/material.dart';
import '../../../../Models/contribution_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte du membre concerné, en haut du modal "Enregistrer une
/// cotisation" — avatar, nom, montant attendu, badge de statut.
class MemberDueCard extends StatelessWidget {
  const MemberDueCard({super.key, required this.member});

  final ContributionMemberSummary member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.neutralGrayLighter,
            child: Icon(Icons.person, color: AppColors.neutralGray, size: 20),
          ),
          SizedBox(width: AppDimensions.spaceSm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      AppLocalizations.t('contribution_expected_label'),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      member.expectedAmount,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.contributionAmountEmphasis),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(AppDimensions.radiusXl)),
            child: Text(
              member.statusLabel,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warningText),
            ),
          ),
        ],
      ),
    );
  }
}