import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

enum AppLogoSize { small, large }

/// Logo Njangi (icône + wordmark). Le fichier icône doit être placé dans
/// assets/images/icone_njangui_no_white.png et déclaré dans pubspec.yaml.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = AppLogoSize.small});

  final AppLogoSize size;

  @override
  Widget build(BuildContext context) {
    final isSmall = size == AppLogoSize.small;
    final iconDim = isSmall ? 95.0 : 95.0;
    final fontSize = isSmall ? 12.0 : 18.0;
    final iconAsset = isSmall
        ? 'assets/images/icone_njangui_no_white.png'
        : 'assets/images/icone_name.png';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          iconAsset,
          width: iconDim,
          height: iconDim,
        ),
        const SizedBox(width: 6),
        Text(
          isSmall ? '' : '',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isSmall ? FontWeight.w600 : FontWeight.w700,
            letterSpacing: isSmall ? 1.2 : 0,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}