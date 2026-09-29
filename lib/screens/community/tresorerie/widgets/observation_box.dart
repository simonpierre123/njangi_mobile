import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Bandeau "Observation" — citation sur fond teinté clair.
class ObservationBox extends StatelessWidget {
  const ObservationBox({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.profileBannerBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Text(
        '"$text"',
        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.stepGreen),
      ),
    );
  }
}