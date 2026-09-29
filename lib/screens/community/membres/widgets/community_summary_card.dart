import 'package:flutter/material.dart';
import '../../../../Models/community_members_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte verte "La communauté" — stats globales + aperçu des avatars.
/// Le nombre de stats affichées varie (le "en retard" n'apparaît que
/// côté admin, via [CommunitySummary.lateCount] nullable).
class CommunitySummaryCard extends StatelessWidget {
  const CommunitySummaryCard({super.key, required this.summary, this.previewCount = 3});

  final CommunitySummary summary;
  final int previewCount;

  @override
  Widget build(BuildContext context) {
    final statsParts = [
      '${summary.totalMembers} ${AppLocalizations.t('members_label')}',
      '${summary.adminCount} Admin',
      '${summary.activeCount} ${AppLocalizations.t('active_label')}',
      if (summary.lateCount != null) '${summary.lateCount} ${AppLocalizations.t('late_label')}',
    ];

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
            children: [
              const Icon(Icons.groups_outlined, color: AppColors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.t('the_community'),
                style: const TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          Text(
            statsParts.join(' • '),
            style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '${AppLocalizations.t('current_cycle_label').toUpperCase()} : ${summary.cycleLabel}',
            style: TextStyle(
              color: AppColors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          _AvatarPreviewRow(total: summary.totalMembers, previewCount: previewCount),
        ],
      ),
    );
  }
}

class _AvatarPreviewRow extends StatelessWidget {
  const _AvatarPreviewRow({required this.total, required this.previewCount});

  final int total;
  final int previewCount;

  @override
  Widget build(BuildContext context) {
    final remaining = total - previewCount;
    const circleSize = 32.0;
    const overlap = 12.0; // chevauchement entre chaque cercle
    final itemCount = previewCount + (remaining > 0 ? 1 : 0);
    final totalWidth = circleSize + (itemCount - 1) * (circleSize - overlap);

    return SizedBox(
      width: totalWidth,
      height: circleSize,
      child: Stack(
        children: [
          for (var i = 0; i < previewCount; i++)
            Positioned(
              left: i * (circleSize - overlap),
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.3),
                  border: Border.all(color: AppColors.mediumGreen, width: 2),
                ),
              ),
            ),
          if (remaining > 0)
            Positioned(
              left: previewCount * (circleSize - overlap),
              child: Container(
                width: circleSize,
                height: circleSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: AppColors.mediumGreen, width: 2),
                ),
                child: Text(
                  '+$remaining',
                  style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}