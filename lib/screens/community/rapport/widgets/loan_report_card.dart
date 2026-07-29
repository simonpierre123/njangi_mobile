import 'package:flutter/material.dart';
import '../../../../Models/report_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "Détails des Prêts" — 2 mini-stats côte à côte + montant total.
class LoanReportCard extends StatelessWidget {
  const LoanReportCard({super.key, required this.data});

  final LoanReportDetails data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(color: AppColors.mintPale, shape: BoxShape.circle),
                child: const Icon(Icons.description_outlined, size: 15, color: AppColors.primaryDeepest),
              ),
              SizedBox(width: AppDimensions.spaceXs.w),
              Text(
                AppLocalizations.t('loan_details_section'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Row(
            children: [
              Expanded(
                child: _MiniStat(label: AppLocalizations.t('active_loans_word'), value: '${data.activeLoans}'),
              ),
              SizedBox(width: AppDimensions.spaceSm.w),
              Expanded(
                child: _MiniStat(label: AppLocalizations.t('repayment_word'), value: data.repaymentRateLabel),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceSm.w, vertical: AppDimensions.spaceSm.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.t('total_loan_amount_label').toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  data.totalLoanAmount,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceSm.w, vertical: AppDimensions.spaceSm.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}