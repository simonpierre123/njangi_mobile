import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../localization/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/media_picker.dart';

/// Affiche un choix "Prendre une photo" / "Choisir depuis la galerie"
/// en bottom sheet, puis retourne le fichier choisi (ou null si annulé
/// à n'importe quelle étape).
///
/// Réutilisé partout où il n'y a qu'UN seul bouton combiné pour cette
/// action — là où il y a déjà 2 boutons séparés caméra/galerie
/// (Décaissement, KYC Étape 3), on appelle directement MediaPicker.
Future<XFile?> showMediaSourceSheet(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusCard)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceMd.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryDark),
              title: Text(AppLocalizations.t('kyc_take_photo')),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryDark),
              title: Text(AppLocalizations.t('kyc_choose_from_gallery')),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    ),
  );

  if (source == null || !context.mounted) return null;
  return source == ImageSource.camera ? MediaPicker.pickFromCamera() : MediaPicker.pickFromGallery();
}