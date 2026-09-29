import 'package:flutter/material.dart';
import '../../../../Models/community_admin_dashboard_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte "Gestion des prêts" — vue synthétique pour l'admin.
class LoansManagementCard extends StatelessWidget {
  const LoansManagementCard({super.key, required this.stats});

  final LoanStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          _LoanRow(label: AppLocalizations.t('active_loans'), value: '${stats.activeLoans}'),
          const Divider(height: 1, color: AppColors.divider),
          _LoanRow(label: AppLocalizations.t('pending_requests'), value: '${stats.pendingRequests}'),
          const Divider(height: 1, color: AppColors.divider),
          _LoanRow(label: AppLocalizations.t('overdue_label'), value: '${stats.overdue}'),
          SizedBox(height: AppDimensions.spaceMd.h),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.iconBgMint,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.borderMint),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.t('borrowing_capacity').toUpperCase(),
                  style: const TextStyle(color: AppColors.primaryDark, fontSize: 10, fontWeight: FontWeight.w700),
                ),
                Text(
                  stats.borrowingCapacity,
                  style: const TextStyle(color: AppColors.primaryDark, fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanRow extends StatelessWidget {
  const _LoanRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}