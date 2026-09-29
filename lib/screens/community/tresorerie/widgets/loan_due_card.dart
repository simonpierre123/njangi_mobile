import 'package:flutter/material.dart';
import '../../../../Models/treasury_model.dart';
import '../../../../localization/app_localizations.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Carte claire "Prochaine échéance" de remboursement du prêt.
class LoanDueCard extends StatelessWidget {
  const LoanDueCard({super.key, required this.due});

  final LoanDueInfo due;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spaceMd.w),
      decoration: BoxDecoration(
        color: AppColors.primaryDark10,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: AppColors.primaryDark, shape: BoxShape.circle),
            child: const Icon(Icons.event_repeat, color: AppColors.white, size: 18),
          ),
          SizedBox(width: AppDimensions.spaceSm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.t('next_due_date'),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(due.dueDate, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
              ],
            ),
          ),
          Text(
            due.amount,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.secondaryGreen),
          ),
        ],
      ),
    );
  }
}