import 'package:flutter/material.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Rappelle que les invitations ne sont pas encore envoyées au backend.
class InviteSimulationBanner extends StatelessWidget {
  const InviteSimulationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceSm.w),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.science_outlined,
            size: 16,
            color: AppColors.warningText,
          ),
          SizedBox(width: AppDimensions.spaceXs.w),
          Expanded(
            child: Text(
              AppLocalizations.t('invite_simulation_banner'),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.warningText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
