import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Ligne simple de paramètre (icône + libellé + chevron), sans fond
/// coloré ni sous-titre — utilisée dans la liste "Paramètres".
class SettingsRow extends StatelessWidget {
  const SettingsRow({super.key, required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceXs.w, vertical: AppDimensions.spaceSm.h),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            SizedBox(width: AppDimensions.spaceSm.w),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}