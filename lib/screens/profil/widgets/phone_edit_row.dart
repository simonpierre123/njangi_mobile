import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Bloc numéro de téléphone en lecture seule + lien "Modifier" + note
/// d'avertissement (le changement nécessite une nouvelle vérification SMS).
class PhoneEditRow extends StatelessWidget {
  const PhoneEditRow({super.key, required this.phone, required this.onChangeTap});

  final String phone;
  final VoidCallback onChangeTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.t('phone_number_label'),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        SizedBox(height: AppDimensions.spaceXs.h),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, size: 16, color: AppColors.primaryDark),
              const SizedBox(width: 8),
              Expanded(child: Text(phone, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
              GestureDetector(
                onTap: onChangeTap,
                child: Text(
                  AppLocalizations.t('change_number_link'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.spaceXs.h),
        Text(
          AppLocalizations.t('change_number_notice'),
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}