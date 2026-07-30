import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../common/basewidget/media_source_sheet.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Sélecteur de photo de communauté (Étape 1/5) — fonctionnel : ouvre
/// un choix caméra/galerie réel et affiche l'image choisie.
///
/// NB : bordure pointillée non disponible nativement dans Flutter sans
/// CustomPainter dédié — approximée ici par une bordure fine pleine.
class CommunityPhotoPicker extends StatefulWidget {
  const CommunityPhotoPicker({super.key, this.onImagePicked});

  final ValueChanged<String>? onImagePicked;

  @override
  State<CommunityPhotoPicker> createState() => _CommunityPhotoPickerState();
}

class _CommunityPhotoPickerState extends State<CommunityPhotoPicker> {
  File? _image;

  Future<void> _pick() async {
    final file = await showMediaSourceSheet(context);
    if (file == null) return;
    setState(() => _image = File(file.path));
    widget.onImagePicked?.call(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _pick,
        child: SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover, width: 96, height: 96)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.photo_camera_outlined, color: AppColors.textSecondary, size: 22),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.t('add_photo_label'),
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(Icons.add, color: AppColors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}