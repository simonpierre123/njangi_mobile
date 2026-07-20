import 'package:flutter/material.dart';
import '../../../../Models/community_admin_dashboard_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "Cycle en cours" — progression, prochain bénéficiaire, cycles
/// restants.
class CycleProgressCard extends StatelessWidget {
  const CycleProgressCard({super.key, required this.cycle});

  final CycleInfo cycle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceLg.w),
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
                AppLocalizations.t('current_cycle'),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mintPale,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  '${AppLocalizations.t('cycle_word')} ${cycle.currentCycle} ${AppLocalizations.t('of_word')} ${cycle.totalCycle}',
                  style: const TextStyle(color: AppColors.primaryDark, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.t('progress_word'), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              Text('${(cycle.progressPercent * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: cycle.progressPercent,
              backgroundColor: AppColors.neutralPill,
              color: AppColors.primaryDark,
              minHeight: 8,
            ),
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Row(
            children: [
              Expanded(
                child: _InfoBox(label: AppLocalizations.t('next_beneficiary'), value: cycle.nextBeneficiary),
              ),
              SizedBox(width: AppDimensions.spaceSm.w),
              Expanded(
                child: _InfoBox(
                  label: AppLocalizations.t('remaining_label'),
                  value: '${cycle.remainingCycles} ${AppLocalizations.t('cycles_word')}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
    );
  }
}