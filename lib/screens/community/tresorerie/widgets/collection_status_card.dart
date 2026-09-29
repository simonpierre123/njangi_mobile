import 'package:flutter/material.dart';
import '../../../../Models/treasury_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "État de la collecte" — onglet "Contributions". La barre de
/// progression est segmentée : vert (à jour), or (en attente), gris
/// (reste à échoir).
class CollectionStatusCard extends StatelessWidget {
  const CollectionStatusCard({super.key, required this.status});

  final CollectionStatus status;

  @override
  Widget build(BuildContext context) {
    final upToDateFraction = (status.upToDateCount / status.totalMembers).clamp(0.0, 1.0);
    final pendingFraction = (status.pendingCount / status.totalMembers).clamp(0.0, 1.0 - upToDateFraction);
    final restFraction = (1 - upToDateFraction - pendingFraction).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceLg.w),
      decoration: BoxDecoration(
        color: AppColors.mediumGreen,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.t('collection_status').toUpperCase(),
                style: TextStyle(color: AppColors.white70, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ),
              Text(
                '${(status.percent * 100).round()}%',
                style: const TextStyle(color: AppColors.white, fontSize: 30, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceXs.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(status.collectedAmount, style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('/ ${status.targetAmount}', style: TextStyle(color: AppColors.white70, fontSize: 13)),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(flex: (upToDateFraction * 100).round().clamp(1, 100), child: Container(color: AppColors.primary)),
                  Expanded(flex: (pendingFraction * 100).round().clamp(1, 100), child: Container(color: AppColors.amber)),
                  Expanded(
                    flex: (restFraction * 100).round().clamp(1, 100),
                    child: Container(color: AppColors.white.withValues(alpha: 0.15)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(label: AppLocalizations.t('members_up_to_date'), value: '${status.upToDateCount}/${status.totalMembers}'),
              _Stat(label: AppLocalizations.t('pending_label'), value: '${status.pendingCount}'),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.t('next_due_date'), style: TextStyle(color: AppColors.white70, fontSize: 12)),
              Text(status.nextDueDate, style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w700)),
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
        Text(label, style: TextStyle(color: AppColors.white70, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}