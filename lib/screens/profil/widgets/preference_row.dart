import 'package:flutter/material.dart';
import '../../../Models/preferences_model.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Ligne de préférence — icône colorée, titre/sous-titre, pastille de
/// valeur actuelle optionnelle, chevron.
class PreferenceRow extends StatelessWidget {
  const PreferenceRow({
    super.key,
    required this.item,
    required this.onTap,
    this.valueOverride,
  });

  final PreferenceItem item;
  final VoidCallback onTap;
  // Permet d'afficher une valeur dynamique (ex: langue actuelle) sans
  // dépendre des données mock statiques.
  final String? valueOverride;

  @override
  Widget build(BuildContext context) {
    final value = valueOverride ?? (item.valueLabel != null ? AppLocalizations.t(item.valueLabel!) : null);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceMd.w, vertical: AppDimensions.spaceSm.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: item.iconBg, shape: BoxShape.circle),
                child: Icon(item.icon, size: 18, color: item.iconColor),
              ),
              SizedBox(width: AppDimensions.spaceSm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.t(item.titleKey),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.t(item.subtitleKey),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (value != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.tagMintBg, borderRadius: BorderRadius.circular(AppDimensions.radiusXl)),
                  child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                ),
                const SizedBox(width: 6),
              ],
              const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}