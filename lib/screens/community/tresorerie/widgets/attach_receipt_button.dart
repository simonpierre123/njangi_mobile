import 'package:flutter/material.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Bouton pilule "Ajouter un reçu" — bordé, icône d'import + texte.
class AttachReceiptButton extends StatelessWidget {
  const AttachReceiptButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceSm.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 16, color: AppColors.primaryDark),
              SizedBox(width: AppDimensions.spaceXs.w),
              Text(
                AppLocalizations.t('add_receipt_button'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}