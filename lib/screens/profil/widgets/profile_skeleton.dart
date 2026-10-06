import 'package:flutter/material.dart';
import '../../../common/basewidget/shimmer_loading.dart';
import '../../../utils/app_dimensions.dart';

/// Placeholder des pages profil pendant la lecture de l'utilisateur connecté.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH.w,
          vertical: AppDimensions.spaceMd.h,
        ),
        child: Column(
          children: [
            const SkeletonBox(width: 90, height: 90, isCircle: true),
            SizedBox(height: AppDimensions.spaceSm.h),
            const SkeletonBox(width: 160, height: 20),
            SizedBox(height: AppDimensions.spaceLg.h),
            for (var i = 0; i < 5; i++) ...[
              SkeletonBox(height: 56, radius: AppDimensions.radiusMd),
              SizedBox(height: AppDimensions.spaceSm.h),
            ],
          ],
        ),
      ),
    );
  }
}
