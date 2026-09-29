import 'dart:io';
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../common/basewidget/network_avatar.dart';

/// Avatar circulaire avec un badge en overlay (coche de vérification par
/// défaut, ou icône appareil photo en mode édition).
///
/// [imageFile] optionnel — si fourni, affiche la vraie photo choisie
/// par l'utilisateur ; sinon, visage de démonstration (NetworkAvatar,
/// avec repli automatique sur l'icône générique hors-ligne).
///
/// NB : dart:io File ne fonctionne pas sur Flutter Web (pas de système
/// de fichiers dans le navigateur) — l'aperçu photo réellement choisie
/// fonctionnera sur Android/iOS/desktop mais pas dans Chrome/Edge.
class AvatarWithBadge extends StatelessWidget {
  const AvatarWithBadge({
    super.key,
    this.size = 80,
    this.badgeIcon = Icons.check,
    this.onBadgeTap,
    this.imageFile,
  });

  final double size;
  final IconData badgeIcon;
  final VoidCallback? onBadgeTap;
  final File? imageFile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.neutralGrayLight),
            child: imageFile != null
                ? Image.file(imageFile!, fit: BoxFit.cover, width: size, height: size)
                : NetworkAvatar(radius: size / 2, seed: 68),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: GestureDetector(
              onTap: onBadgeTap,
              child: Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: Icon(badgeIcon, color: AppColors.white, size: size * 0.16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}