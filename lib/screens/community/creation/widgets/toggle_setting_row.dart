import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Ligne de paramètre à bascule — [leading] est totalement libre
/// (icône en cercle coloré, icône simple, ou rien) pour couvrir les
/// différents styles vus sur la maquette "Règles de fonctionnement"
/// (certaines lignes ont une icône en cercle, d'autres une icône
/// simple, d'autres aucune icône).
class ToggleSettingRow extends StatelessWidget {
  const ToggleSettingRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.bordered = true,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          SizedBox(width: AppDimensions.spaceSm.w),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.white,
          activeTrackColor: AppColors.secondaryGreen,
          inactiveThumbColor: AppColors.white,
          inactiveTrackColor: AppColors.toggleInactiveTrack,
        ),
      ],
    );

    if (!bordered) return row;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceMd.w, vertical: AppDimensions.spaceSm.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: row,
    );
  }
}

/// Icône dans un cercle coloré — même style que les icônes "Cotisation"
/// / "Cycle" de l'Étape 2 (cercle #AAF1D2, icône #002116).
class CircledSettingIcon extends StatelessWidget {
  const CircledSettingIcon({super.key, required this.icon, this.size = 32});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: AppColors.mintPale, shape: BoxShape.circle),
      child: Icon(icon, size: size * 0.5, color: AppColors.primaryDeepest),
    );
  }
}