import 'package:flutter/material.dart';
import '../../../../Models/report_model.dart';
import '../../../../common/basewidget/network_avatar.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Ligne de transaction — "Dernières opérations" (Rapport détaillé).
class ReportTransactionRow extends StatelessWidget {
  const ReportTransactionRow({super.key, required this.transaction});

  final ReportTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.spaceMd.w, vertical: AppDimensions.spaceSm.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          NetworkAvatar(radius: 18, seed: transaction.memberName.hashCode.abs() % 70 + 1),
          SizedBox(width: AppDimensions.spaceSm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.memberName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(transaction.dateLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(transaction.amountLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(
                transaction.statusLabel,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: transaction.isPaid ? AppColors.secondaryGreen : AppColors.warningText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}