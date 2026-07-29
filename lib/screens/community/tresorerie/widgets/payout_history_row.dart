import 'package:flutter/material.dart';
import '../../../../Models/beneficiary_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Contenu d'une ligne de l'historique des versements — icône de
/// confirmation, nom, cycle, montant, statut "Effectué".
///
/// Pas de carte propre : plusieurs lignes sont regroupées dans une
/// seule carte commune par le parent, comme sur la maquette.
class PayoutHistoryRow extends StatelessWidget {
  const PayoutHistoryRow({super.key, required this.entry});

  final PayoutHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: AppColors.tagMintBg, shape: BoxShape.circle),
          child: const Icon(Icons.check, size: 16, color: AppColors.primaryDark),
        ),
        SizedBox(width: AppDimensions.spaceSm.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(entry.cycleLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(entry.amount, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(
              AppLocalizations.t('completed_status'),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.secondaryGreen),
            ),
          ],
        ),
      ],
    );
  }
}