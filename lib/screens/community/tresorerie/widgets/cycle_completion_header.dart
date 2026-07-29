import 'package:flutter/material.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// En-tête de l'écran "Cycle terminé" — illustration (asset fourni par
/// Njoya : assets/images/cycle_finish.png, inclut déjà l'icône verte),
/// titre, sous-titre, communauté + date de clôture.
///
/// TODO (Njoya) : s'assurer que cycle_finish.png est bien déclaré dans
/// pubspec.yaml sous assets/images/ (déjà le cas pour ce dossier selon
/// l'architecture initiale — vérifie juste que le fichier y est copié).
class CycleCompletionHeader extends StatelessWidget {
  const CycleCompletionHeader({
    super.key,
    required this.communityName,
    required this.closedDateLabel,
  });

  final String communityName;
  final String closedDateLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          child: Image.asset(
            'assets/images/cycle_finish.png',
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 140,
              color: AppColors.tagMintBg,
              alignment: Alignment.center,
              child: const Icon(Icons.image_outlined, size: 32, color: AppColors.primaryDark),
            ),
          ),
        ),
        SizedBox(height: AppDimensions.spaceLg.h),
        Text(
          AppLocalizations.t('cycle_completed_title'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        SizedBox(height: AppDimensions.spaceXs.h),
        Text(
          AppLocalizations.t('cycle_completed_subtitle'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        SizedBox(height: AppDimensions.spaceSm.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.groups_outlined, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(communityName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            SizedBox(width: AppDimensions.spaceSm.w),
            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(closedDateLabel, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}