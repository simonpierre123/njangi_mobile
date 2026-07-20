import 'package:flutter/material.dart';
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
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.mintSurface,
          child: Icon(Icons.person, color: AppColors.primaryDark),
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