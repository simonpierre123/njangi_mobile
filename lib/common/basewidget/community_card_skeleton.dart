import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import 'shimmer_loading.dart';

/// Placeholder de [CommunityCard] affiché pendant le chargement des groupes.
class CommunityCardSkeleton extends StatelessWidget {
  const CommunityCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppDimensions.spaceMd.w),
        margin: EdgeInsets.only(bottom: AppDimensions.spaceMd.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(
                  width: 48,
                  height: 48,
                  radius: AppDimensions.radiusLg,
                ),
                SizedBox(width: AppDimensions.spaceSm.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBox(width: 140, height: 16),
                      SizedBox(height: 8),
                      SkeletonBox(width: 90, height: 11),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.spaceLg.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonBox(width: 90, height: 24),
                SkeletonBox(width: 80, height: 24),
              ],
            ),
            SizedBox(height: AppDimensions.spaceLg.h),
            const SkeletonBox(height: 6, radius: 10),
            SizedBox(height: AppDimensions.spaceMd.h),
            const SkeletonBox(width: 120, height: 12),
          ],
        ),
      ),
    );
  }
}
