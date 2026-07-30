import 'package:flutter/material.dart';
import '../../../common/basewidget/network_avatar.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';

/// En-tête d'accueil du tableau de bord (avatar + salutation).
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const NetworkAvatar(
          radius: 20,
          seed: 68,
          fallbackBg: AppColors.mintSurface,
          fallbackIconColor: AppColors.primaryDark,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.t('greeting_hello')}, $userName 👋',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            Text(
              AppLocalizations.t('greeting_subtitle'),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}