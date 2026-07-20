import 'package:flutter/material.dart';
import '../../../../Models/treasury_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "Votre éligibilité" — plafond disponible, ancienneté, historique.
class LoanEligibilityCard extends StatelessWidget {
  const LoanEligibilityCard({super.key, required this.eligibility});

  final LoanEligibility eligibility;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceLg.w),
      decoration: BoxDecoration(
        color: AppColors.mintSurfaceLighter,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.t('your_eligibility'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Row(
            children: [
              Expanded(child: _Stat(label: AppLocalizations.t('available_limit'), value: eligibility.availableLimit)),
              Expanded(child: _Stat(label: AppLocalizations.t('seniority_label'), value: eligibility.seniorityLabel)),
            ],
          ),
          if (eligibility.hasGoodHistory) ...[
            SizedBox(height: AppDimensions.spaceMd.h),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: AppColors.primaryDark),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppLocalizations.t('good_repayment_history'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }
}