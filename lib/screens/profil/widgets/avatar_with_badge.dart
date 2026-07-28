import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';

/// Avatar circulaire avec un badge en overlay (coche de vérification par
/// défaut, ou icône appareil photo en mode édition).
///
/// TODO (Njoya) : pas de vraie photo utilisateur pour l'instant (pas de
/// stockage/upload branché) — icône placeholder générique.
class AvatarWithBadge extends StatelessWidget {
  const AvatarWithBadge({
    super.key,
    this.size = 80,
    this.badgeIcon = Icons.check,
    this.onBadgeTap,
  });

  final double size;
  final IconData badgeIcon;
  final VoidCallback? onBadgeTap;

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
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.neutralGrayLight),
            child: Icon(Icons.person, color: AppColors.white, size: size * 0.45),
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