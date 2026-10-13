import 'dart:async';

import 'package:flutter/material.dart';
import '../../../common/basewidget/shimmer_loading.dart';
import '../../../localization/app_localizations.dart';
import '../../../utils/app_colors.dart';

/// En-tête d'accueil du tableau de bord (avatar + salutation).
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.userName,
    required this.photoUrl,
    required this.subtitleKey,
    required this.onLock,
  });

  final String userName;
  final String? photoUrl;
  final String? subtitleKey;
  final Future<void> Function() onLock;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child:
              photoUrl == null
                  ? Container(
                    width: 40,
                    height: 40,
                    color: AppColors.mintSurface,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primaryDark,
                    ),
                  )
                  : ShimmerNetworkImage(
                    url: photoUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 40,
                          height: 40,
                          color: AppColors.mintSurface,
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primaryDark,
                          ),
                        ),
                  ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.t('greeting_hello')}, $userName 👋',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitleKey != null)
                Text(
                  AppLocalizations.t(subtitleKey!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          tooltip: AppLocalizations.t('lock_app_tooltip'),
          onPressed: () => unawaited(onLock()),
          icon: const Icon(Icons.lock_outline_rounded),
          color: AppColors.primaryDark,
        ),
      ],
    );
  }
}
