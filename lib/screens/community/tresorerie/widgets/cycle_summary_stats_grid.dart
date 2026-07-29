import 'package:flutter/material.dart';
import '../../../../Models/cycle_completion_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Grille 2x2 du résumé de cycle — mêmes tuiles que BeneficiaryStatsGrid
/// visuellement, mais 4e statistique différente (Prêts au lieu de
/// Restants, puisque tous les bénéficiaires ont déjà été servis ici).
class CycleSummaryStatsGrid extends StatelessWidget {
  const CycleSummaryStatsGrid({super.key, required this.stats});

  final CycleSummaryStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.people_outline,
                label: AppLocalizations.t('members_word'),
                value: '${stats.totalMembers}',
              ),
            ),
            SizedBox(width: AppDimensions.spaceSm.w),
            Expanded(
              child: _StatTile(
                icon: Icons.emoji_events_outlined,
                label: AppLocalizations.t('pot_label'),
                value: stats.potAmount,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spaceSm.h),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.check_circle_outline,
                label: AppLocalizations.t('served_label'),
                value: stats.servedRatio,
              ),
            ),
            SizedBox(width: AppDimensions.spaceSm.w),
            Expanded(
              child: _StatTile(
                icon: Icons.hourglass_empty,
                label: AppLocalizations.t('loans_word'),
                value: '${stats.activeLoans}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                label.toUpperCase(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}