import 'package:flutter/material.dart';
import '../../../../Models/beneficiary_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte du bénéficiaire en haut du modal "Enregistrer un
/// décaissement" — réutilise directement [CurrentBeneficiary] (name,
/// subtitle, amount déjà présents), pas besoin d'un modèle séparé.
class BeneficiaryDueCard extends StatelessWidget {
  const BeneficiaryDueCard({super.key, required this.beneficiary});

  final CurrentBeneficiary beneficiary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.neutralGrayLighter,
            child: Icon(Icons.person, color: AppColors.neutralGray, size: 20),
          ),
          SizedBox(width: AppDimensions.spaceSm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(beneficiary.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(beneficiary.subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppLocalizations.t('amount_due_label'),
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                beneficiary.amount,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.contributionAmountEmphasis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}