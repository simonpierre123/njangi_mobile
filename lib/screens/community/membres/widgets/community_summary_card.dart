import 'package:flutter/material.dart';
import '../../../../ModeView/community_members_model.dart';
import '../../../../common/basewidget/network_avatar.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_constants.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte verte "La communauté" — stats globales + aperçu des avatars.
/// Le nombre de stats affichées varie (le "en retard" n'apparaît que
/// côté admin, via [CommunitySummary.lateCount] nullable).
class CommunitySummaryCard extends StatelessWidget {
  const CommunitySummaryCard({
    super.key,
    required this.summary,
    this.previewMemberPhotoUrls = const [],
    this.previewCount = 3,
  });

  final CommunitySummary summary;
  final List<String?> previewMemberPhotoUrls;
  final int previewCount;

  @override
  Widget build(BuildContext context) {
    final statsParts = [
      '${summary.totalMembers} ${AppLocalizations.t('members_label')}',
      '${summary.adminCount} Admin',
      '${summary.activeCount} ${AppLocalizations.t('active_label')}',
      if (summary.lateCount != null)
        '${summary.lateCount} ${AppLocalizations.t('late_label')}',
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
              const Icon(
                Icons.groups_outlined,
                color: AppColors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.t('the_community'),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          Text(
            statsParts.join(' • '),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
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
          _AvatarPreviewRow(
            previewCount: previewCount,
            photoUrls: previewMemberPhotoUrls,
          ),
        ],
      ),
    );
  }
}

class _AvatarPreviewRow extends StatelessWidget {
  const _AvatarPreviewRow({
    required this.previewCount,
    required this.photoUrls,
  });

  final int previewCount;
  final List<String?> photoUrls;

  @override
  Widget build(BuildContext context) {
    const circleSize = 32.0;
    const overlap = 12.0; // chevauchement entre chaque cercle
    final itemCount =
        photoUrls.isEmpty ? previewCount : photoUrls.length.clamp(0, previewCount);
    if (itemCount == 0) return const SizedBox.shrink();
    final totalWidth = circleSize + (itemCount - 1) * (circleSize - overlap);

    return SizedBox(
      width: totalWidth,
      height: circleSize,
      child: Stack(
        children: [
          for (var i = 0; i < itemCount; i++)
            Positioned(
              left: i * (circleSize - overlap),
              child: Container(
                width: circleSize,
                height: circleSize,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mediumGreen,
                  border: Border.all(color: AppColors.mediumGreen, width: 2),
                ),
                child: NetworkAvatar(
                  radius: (circleSize - 4) / 2,
                  seed: i + 1,
                  imageUrl: _mediaUrl(photoUrls.isEmpty ? null : photoUrls[i]),
                  fallbackIcon: null,
                  fallbackBg: AppColors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String? _mediaUrl(String? path) {
    final value = path?.trim();
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('http')) return value;
    return '${AppConstants.imageBaseUrl}${value.replaceFirst(RegExp(r'^/+'), '')}';
  }
}
