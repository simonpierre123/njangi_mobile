import 'package:flutter/material.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';
import '../../../../utils/media_picker.dart';

/// Grille 2 colonnes des sources de justificatif — "Prendre une photo"
/// / "Depuis galerie". Fonctionnel : chaque bouton ouvre réellement la
/// caméra ou la galerie, et affiche une coche une fois un fichier choisi.
class ReceiptSourceGrid extends StatefulWidget {
  const ReceiptSourceGrid({super.key, this.onFilePicked});

  final ValueChanged<String>? onFilePicked;

  @override
  State<ReceiptSourceGrid> createState() => _ReceiptSourceGridState();
}

class _ReceiptSourceGridState extends State<ReceiptSourceGrid> {
  bool _pickedFromCamera = false;
  bool _pickedFromGallery = false;

  Future<void> _takePhoto() async {
    final file = await MediaPicker.pickFromCamera();
    if (file == null) return;
    setState(() {
      _pickedFromCamera = true;
      _pickedFromGallery = false;
    });
    widget.onFilePicked?.call(file.path);
  }

  Future<void> _fromGallery() async {
    final file = await MediaPicker.pickFromGallery();
    if (file == null) return;
    setState(() {
      _pickedFromGallery = true;
      _pickedFromCamera = false;
    });
    widget.onFilePicked?.call(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SourceTile(
            icon: Icons.camera_alt_outlined,
            label: AppLocalizations.t('take_photo_button'),
            isPicked: _pickedFromCamera,
            onTap: _takePhoto,
          ),
        ),
        SizedBox(width: AppDimensions.spaceSm.w),
        Expanded(
          child: _SourceTile(
            icon: Icons.photo_library_outlined,
            label: AppLocalizations.t('from_gallery_button'),
            isPicked: _pickedFromGallery,
            onTap: _fromGallery,
          ),
        ),
      ],
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.icon, required this.label, required this.isPicked, required this.onTap});

  final IconData icon;
  final String label;
  final bool isPicked;
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
            border: Border.all(color: isPicked ? AppColors.secondaryGreen : AppColors.inputBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isPicked ? Icons.check_circle : icon, size: 20, color: isPicked ? AppColors.secondaryGreen : AppColors.textSecondary),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPicked ? AppColors.secondaryGreen : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}