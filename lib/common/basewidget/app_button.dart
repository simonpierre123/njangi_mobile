import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_dimensions.dart';

enum AppButtonVariant { primary, secondary }

/// Bouton réutilisable (350x52 en référence Figma, largeur adaptable).
/// - primary   : fond vert foncé plein (CTA principal)
/// - secondary : fond vert clair léger (action secondaire)
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.iconLeading = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool iconLeading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == AppButtonVariant.primary;

    return SizedBox(
      width: fullWidth ? double.infinity : AppDimensions.buttonWidth,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primaryDark : AppColors.mintSurface,
          foregroundColor: isPrimary ? AppColors.textOnPrimary : AppColors.primaryDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null && iconLeading) ...[
              Icon(icon, size: 18),
              const SizedBox(width: AppDimensions.spaceSm),
            ],
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (icon != null && !iconLeading) ...[
              const SizedBox(width: AppDimensions.spaceSm),
              Icon(icon, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}