import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'shimmer_loading.dart';

/// Avatar utilisateur chargé depuis son profil, avec une image locale
/// commune quand aucune photo n'est enregistrée ou que le chargement échoue.
class NetworkAvatar extends StatelessWidget {
  const NetworkAvatar({
    super.key,
    required this.radius,
    required this.seed,
    this.imageUrl,
    this.fallbackIcon = Icons.person,
    this.fallbackIconColor = AppColors.neutralGray,
    this.fallbackBg = AppColors.neutralGrayLighter,
  });

  final double radius;
  final String? imageUrl;
  // Conservé pour compatibilité avec les appels existants.
  final int seed;
  final IconData? fallbackIcon;
  final Color fallbackIconColor;
  final Color fallbackBg;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return _defaultAvatar(size);
    }

    return ClipOval(
      child: ShimmerNetworkImage(
        url: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _defaultAvatar(size),
      ),
    );
  }

  Widget _defaultAvatar(double size) => ClipOval(
    child: Image.asset(
      'assets/images/user.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) => Container(
            width: size,
            height: size,
            color: fallbackBg,
            alignment: Alignment.center,
            child:
                fallbackIcon == null
                    ? null
                    : Icon(
                      fallbackIcon,
                      size: radius,
                      color: fallbackIconColor,
                    ),
          ),
    ),
  );
}
