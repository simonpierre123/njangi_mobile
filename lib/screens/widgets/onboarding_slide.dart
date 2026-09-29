import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Contenu d'une slide d'onboarding : illustration (asset réel fourni
/// par Njoya, assets/images/onboarding{1,2,3}.png) + titre + description.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  final String imagePath;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: AppDimensions.spaceLg.h),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.mintSurfaceLighter,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.mintSurfaceLighter, AppColors.white],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(height: AppDimensions.spaceSm.h),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: AppDimensions.spaceLg.h),
        ],
      ),
    );
  }
}