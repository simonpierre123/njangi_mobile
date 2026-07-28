import 'package:flutter/material.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Sélecteur de photo de communauté (Étape 1/5).
///
/// NB : bordure pointillée non disponible nativement dans Flutter sans
/// CustomPainter dédié — approximée ici par une bordure fine pleine.
///
/// TODO (Njoya) : aucun vrai sélecteur d'image branché (pas de package
/// image_picker) — [onTap] est prêt à recevoir cette logique.
class CommunityPhotoPicker extends StatelessWidget {
  const CommunityPhotoPicker({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Column(
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