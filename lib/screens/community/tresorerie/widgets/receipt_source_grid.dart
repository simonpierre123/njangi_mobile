import 'package:flutter/material.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Grille 2 colonnes des sources de justificatif — "Prendre une photo"
/// / "Depuis galerie".
class ReceiptSourceGrid extends StatelessWidget {
  const ReceiptSourceGrid({super.key, required this.onTakePhoto, required this.onFromGallery});

  final VoidCallback onTakePhoto;
  final VoidCallback onFromGallery;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SourceTile(
            icon: Icons.camera_alt_outlined,
            label: AppLocalizations.t('take_photo_button'),
            onTap: onTakePhoto,
          ),
        ),
        SizedBox(width: AppDimensions.spaceSm.w),
        Expanded(
          child: _SourceTile(
            icon: Icons.photo_library_outlined,
            label: AppLocalizations.t('from_gallery_button'),
            onTap: onFromGallery,
          ),
        ),
      ],
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceMd.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}