import 'package:flutter/material.dart';
import '../../../../Models/treasury_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "Ma position financière" — onglet "Ma Trésorerie". Fond vert
/// plein (#3B846C), donc tout le texte est en blanc/blanc atténué.
class FinancialPositionCard extends StatelessWidget {
  const FinancialPositionCard({super.key, required this.position});

  final FinancialPosition position;

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
            children: [
              Text(
                AppLocalizations.t('my_financial_position').toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white70,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                child: Text(
                  '${position.participationPercent}% ${AppLocalizations.t('participation_suffix')}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceSm.h),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.mintLight, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                position.statusLabel,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceLg.h),
          Row(
            children: [
              Expanded(child: _Stat(label: AppLocalizations.t('total_contributed'), value: position.totalContributed)),
              Expanded(child: _Stat(label: AppLocalizations.t('active_loans'), value: position.activeLoanLabel)),
            ],
          ),
          SizedBox(height: AppDimensions.spaceMd.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.t('next_due_date'), style: TextStyle(fontSize: 12, color: AppColors.white70)),
              Text(
                position.nextDueDate,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white),
              ),
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