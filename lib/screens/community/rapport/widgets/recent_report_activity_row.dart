import 'package:flutter/material.dart';
import '../../../../Models/report_model.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';

/// Ligne d'activité récente — icône, "Cotisation de {nom}", montant
/// signé (couleur selon +/-), horodatage.
class RecentReportActivityRow extends StatelessWidget {
  const RecentReportActivityRow({super.key, required this.activity});

  final RecentReportActivity activity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: activity.iconBg, shape: BoxShape.circle),
          child: Icon(activity.icon, size: 16, color: activity.iconColor),
        ),
        SizedBox(width: AppDimensions.spaceSm.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  children: [
                    TextSpan(text: '${activity.titlePrefix} '),
                    TextSpan(text: activity.personName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(activity.timeLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Text(
          activity.amountLabel,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: activity.amountColor,
          ),
        ),
      ],
    );
  }
}