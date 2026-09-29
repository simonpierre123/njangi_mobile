import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Bloc de checklist sur fond vert clair — réutilisé pour "Prérequis"
/// (KYC1) et "Votre document doit être :" (KYC2).
class KycChecklistBox extends StatelessWidget {
  const KycChecklistBox({super.key, this.title, this.leadingIcon, required this.items});

  final String? title;
  final IconData? leadingIcon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.profileBannerBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: 16, color: AppColors.stepGreen),
                  const SizedBox(width: 6),
                ],
                Text(title!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.stepGreen)),
              ],
            ),
            SizedBox(height: AppDimensions.spaceSm.h),
          ],
          for (var i = 0; i < items.length; i++) ...[
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: AppColors.secondaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(items[i], style: const TextStyle(fontSize: 12, color: AppColors.stepGreen)),
                ),
              ],
            ),
            if (i != items.length - 1) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}