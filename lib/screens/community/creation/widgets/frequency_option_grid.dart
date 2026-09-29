import 'package:flutter/material.dart';
import '../../../../Models/create_community_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Grille 2x2 de sélection de la fréquence de cotisation.
class FrequencyOptionGrid extends StatelessWidget {
  const FrequencyOptionGrid({super.key, required this.selected, required this.onSelect});

  final ContributionFrequency? selected;
  final ValueChanged<ContributionFrequency> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppDimensions.spaceSm.w,
      mainAxisSpacing: AppDimensions.spaceSm.h,
      childAspectRatio: 1.9,
      children: [
        for (final freq in ContributionFrequency.values)
          _FrequencyTile(freq: freq, isSelected: selected == freq, onTap: () => onSelect(freq)),
      ],
    );
  }
}

class _FrequencyTile extends StatelessWidget {
  const _FrequencyTile({required this.freq, required this.isSelected, required this.onTap});

  final ContributionFrequency freq;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryDark10,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceMd.w, vertical: AppDimensions.spaceMd.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: isSelected ? AppColors.primaryDark : AppColors.inputBorder, width: isSelected ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.t(freq.titleKey),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                AppLocalizations.t(freq.subtitleKey),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}