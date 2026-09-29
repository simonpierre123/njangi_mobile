import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// Avatar chargé depuis internet (service de photos de démonstration
/// pravatar.cc) — pour donner un visage réaliste aux avatars encore
/// placeholders. Si le réseau échoue (pas de connexion, timeout...),
/// errorBuilder de Image.network reprend automatiquement le placeholder
/// exact déjà utilisé avant (icône générique sur fond neutre), donc
/// rien ne casse hors-ligne.
class NetworkAvatar extends StatelessWidget {
  const NetworkAvatar({
    super.key,
    required this.radius,
    required this.seed,
    this.fallbackIcon = Icons.person,
    this.fallbackIconColor = AppColors.neutralGray,
    this.fallbackBg = AppColors.neutralGrayLighter,
  });

  final double radius;
  // Numéro pravatar.cc (1 à 70) — détermine quel visage est affiché,
  // pour varier les visages d'un avatar à l'autre.
  final int seed;
  final IconData? fallbackIcon;
  final Color fallbackIconColor;
  final Color fallbackBg;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return ClipOval(
      child: Image.network(
        'https://i.pravatar.cc/150?img=$seed',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          color: fallbackBg,
          alignment: Alignment.center,
          child: fallbackIcon != null ? Icon(fallbackIcon, size: radius, color: fallbackIconColor) : null,
        ),
      ),
    );
  }
}