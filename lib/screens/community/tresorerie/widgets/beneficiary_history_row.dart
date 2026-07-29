import 'package:flutter/material.dart';
import '../../../../Models/cycle_completion_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Ligne d'un bénéficiaire déjà servi — avatar, nom, période + montant,
/// badge "Versé".
class BeneficiaryHistoryRow extends StatelessWidget {
  const BeneficiaryHistoryRow({super.key, required this.entry});

  final BeneficiaryHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.neutralGrayLighter,
          child: Icon(Icons.person, size: 18, color: AppColors.neutralGray),
        ),
        SizedBox(width: AppDimensions.spaceSm.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(entry.periodLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 14, color: AppColors.secondaryGreen),
            const SizedBox(width: 4),
            Text(
              AppLocalizations.t('paid_out_status'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondaryGreen),
            ),
          ],
        ),
      ],
    );
  }
}