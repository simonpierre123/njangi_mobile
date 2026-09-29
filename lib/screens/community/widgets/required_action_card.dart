import 'package:flutter/material.dart';
import '../../../../Models/community_member_dashboard_model.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Card individuelle "action requise" (cotisation due, réunion...).
/// Affiche un bouton compact si [item.actionLabel] est renseigné,
/// sinon un chevron (card purement informative, cliquable via [onTap]).
class RequiredActionCard extends StatelessWidget {
  const RequiredActionCard({
    super.key,
    required this.item,
    this.onAction,
    this.onTap,
  });

  final RequiredActionItem item;
  final VoidCallback? onAction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasAction = item.actionLabel != null;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        onTap: hasAction ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.inputBorder),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMd.w,
            vertical: AppDimensions.spaceSm.h,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.iconBgMint, shape: BoxShape.circle),
                child: Icon(item.icon, color: AppColors.primaryDark, size: 18),
              ),
              SizedBox(width: AppDimensions.spaceSm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(item.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (hasAction)
                ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusXl)),
                  ),
                  child: Text(item.actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                )
              else
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}