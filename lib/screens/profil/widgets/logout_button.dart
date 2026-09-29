import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_dimensions.dart';

/// Bouton "Se déconnecter" — pilule rouge clair pleine largeur.
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.tagRedBg,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceSm.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, size: 16, color: AppColors.alertRed),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.t('logout_button'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.alertRed),
              ),
            ],
          ),
        ),
      ),
    );
  }
}