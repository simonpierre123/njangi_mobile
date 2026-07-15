import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Contenu d'une slide d'onboarding : illustration + titre + description.
/// L'illustration réelle (image/lottie) sera intégrée plus tard — un
/// dégradé neutre tient sa place pour l'instant.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.title,
    required this.description,
  });

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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.mintSurfaceLighter, AppColors.white],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
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