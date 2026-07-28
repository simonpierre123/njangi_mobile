import 'package:flutter/material.dart';
import '../../../../Models/report_model.dart';
import '../../../../common/basewidget/percent_ring.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "Participation" — anneau de pourcentage centré + répartition
/// à jour / en retard / partiel.
class ParticipationRingCard extends StatelessWidget {
  const ParticipationRingCard({super.key, required this.data});

  final ParticipationBreakdown data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceLg.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          PercentRing(percent: data.percent, size: 96, strokeWidth: 8),
          SizedBox(height: AppDimensions.spaceSm.h),
          Text(
            '${data.totalMembers} ${AppLocalizations.t('members_word')}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          _LegendRow(color: AppColors.primary, label: AppLocalizations.t('up_to_date'), count: data.upToDateCount),
          const SizedBox(height: 6),
          _LegendRow(color: AppColors.alertRed, label: AppLocalizations.t('overdue_label'), count: data.lateCount),
          const SizedBox(height: 6),
          _LegendRow(color: AppColors.warningText, label: AppLocalizations.t('pending_label'), count: data.partialCount),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label, required this.count});

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const Spacer(),
        Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }
}