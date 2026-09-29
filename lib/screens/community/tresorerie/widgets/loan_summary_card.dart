import 'package:flutter/material.dart';
import '../../../../Models/treasury_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "Mon prêt" — résumé du prêt en cours (onglet "Prêts"). Même
/// habillage vert que FinancialPositionCard, pour rester cohérent avec
/// l'onglet "Ma Trésorerie".
class LoanSummaryCard extends StatelessWidget {
  const LoanSummaryCard({super.key, required this.loan});

  final LoanInfo loan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceLg.w),
      decoration: BoxDecoration(
        color: AppColors.financialPositionBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.t('loan_title'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white),
                  ),
                  SizedBox(height: AppDimensions.spaceXs.h),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                    ),
                    child: Text(
                      loan.statusLabel,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.white),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppLocalizations.t('borrowed_amount'), style: TextStyle(fontSize: 10, color: AppColors.white70)),
                  const SizedBox(height: 4),
                  Text(
                    loan.borrowedAmount,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.t('repayment_label'), style: TextStyle(fontSize: 12, color: AppColors.white70)),
              Text(
                '${(loan.repaymentPercent * 100).round()}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: loan.repaymentPercent,
              backgroundColor: AppColors.white.withValues(alpha: 0.2),
              color: AppColors.secondaryGreen,
              minHeight: 8,
            ),
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          Row(
            children: [
              Expanded(child: _Stat(label: AppLocalizations.t('total_repaid'), value: loan.totalRepaid)),
              Expanded(child: _Stat(label: AppLocalizations.t('remaining_balance'), value: loan.remainingBalance)),
            ],
          ),
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
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.white70)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.white)),
      ],
    );
  }
}