import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Affichage label/valeur en lecture seule (section "Informations
/// personnelles"), optionnellement précédé d'une icône (date d'adhésion).
class ProfileInfoField extends StatelessWidget {
  const ProfileInfoField({super.key, required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceMd.w, vertical: AppDimensions.spaceSm.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
              ],
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}