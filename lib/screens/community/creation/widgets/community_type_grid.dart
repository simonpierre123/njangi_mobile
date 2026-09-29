import 'package:flutter/material.dart';
import '../../../../Models/create_community_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Grille de sélection du type de communauté — 2x2 (Famille/Amis/
/// Entreprise/Association) + "Autre" en pleine largeur en dessous.
class CommunityTypeGrid extends StatelessWidget {
  const CommunityTypeGrid({super.key, required this.selected, required this.onSelect});

  final CommunityType? selected;
  final ValueChanged<CommunityType> onSelect;

  static const _gridTypes = [
    CommunityType.famille,
    CommunityType.amis,
    CommunityType.entreprise,
    CommunityType.association,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.spaceSm.w,
          mainAxisSpacing: AppDimensions.spaceSm.h,
          childAspectRatio: 1.7,
          children: [
            for (final type in _gridTypes)
              _TypeTile(type: type, isSelected: selected == type, onTap: () => onSelect(type)),
          ],
        ),
        SizedBox(height: AppDimensions.spaceSm.h),
        _TypeTile(
          type: CommunityType.autre,
          isSelected: selected == CommunityType.autre,
          onTap: () => onSelect(CommunityType.autre),
          fullWidth: true,
        ),
      ],
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({required this.type, required this.isSelected, required this.onTap, this.fullWidth = false});

  final CommunityType type;
  final bool isSelected;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final content = [
      Icon(type.icon, size: 20, color: isSelected ? AppColors.primaryDark : AppColors.primaryContainer),
      SizedBox(width: fullWidth ? AppDimensions.spaceSm.w : 0, height: fullWidth ? 0 : 6),
      Text(
        AppLocalizations.t(type.labelKey),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
        ),
      ),
    ];

    return Material(
      color: isSelected ? AppColors.mintPale34 : AppColors.primaryDark10,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceMd.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: isSelected ? AppColors.primaryDark : AppColors.inputBorder, width: isSelected ? 1.5 : 1),
          ),
          child: fullWidth
              ? Row(mainAxisAlignment: MainAxisAlignment.center, children: content)
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: content),
        ),
      ),
    );
  }
}