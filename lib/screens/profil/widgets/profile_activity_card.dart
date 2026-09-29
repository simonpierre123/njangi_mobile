import 'package:flutter/material.dart';
import '../../../Models/profile_model.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Carte verte "Mon activité" — grille 2x2 de statistiques.
class ProfileActivityCard extends StatelessWidget {
  const ProfileActivityCard({super.key, required this.activity});

  final ProfileActivity activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceLg.w),
      decoration: BoxDecoration(
        color: AppColors.mediumGreen,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _Stat(label: AppLocalizations.t('stat_communities'), value: '${activity.communitiesCount}')),
              Expanded(child: _Stat(label: 'Admin', value: '${activity.adminCount}')),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Row(
            children: [
              Expanded(child: _Stat(label: AppLocalizations.t('contributions_label'), value: activity.totalContributions)),
              Expanded(child: _Stat(label: AppLocalizations.t('active_loans'), value: '${activity.activeLoans}')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.white70, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white)),
      ],
    );
  }
}